# Dispatch + runtime (core engine)

## Routes
```rb
# config/routes.rb (host app)
post "/vcr/dispatch", to: "view_component_reducible/dispatch#call"
```

Gem provides railtie to auto-append routes optionally (v0: keep manual).

## Controller
Responsibilities:
- load envelope via adapter
- build msg
- dispatch (route by path)
- run reducer/effects
- render HTML (full or partial)
- include updated signed state in response HTML

```rb
# lib/view_component_reducible/dispatch/controller.rb
module ViewComponentReducible
  module Dispatch
    class Controller < ActionController::Base
      protect_from_forgery with: :exception

      def call
        adapter = ViewComponentReducible.config.adapter_for(self)
        envelope = adapter.load(request:)
        msg = ViewComponentReducible::Msg.from_params(params)
        target_path = params.fetch("vcr_target_path", envelope["path"])

        new_envelope, html = ViewComponentReducible::Runtime.new.call(
          envelope:,
          msg:,
          target_path:,
          controller: self
        )

        signed = adapter.dump(new_envelope, request:)
        render html: ViewComponentReducible::Dispatch.inject_state(html, signed), content_type: "text/html"
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        render status: 400, plain: "Invalid state signature"
      end
    end

    # inject updated hidden field(s) into response
    # v0.1: simplest: embed as <meta> and JS updates hidden input
    def self.inject_state(html, signed_state)
      meta = %(<meta name="vcr-state" content="#{ERB::Util.html_escape(signed_state)}">)
      html.include?("</head>") ? html.sub("</head>", "#{meta}</head>") : (meta + html)
    end
  end
end
```

## Component registry
```rb
# lib/view_component_reducible.rb
module ViewComponentReducible
  class << self
    def registry
      @registry ||= {}
    end

    # called by railtie or user initializer
    def register(component_klass)
      registry[component_klass.vcr_id] = component_klass
    end
  end
end
```

## Routing by path
Path format:
- `"root"` for root
- `"root/0/2"` for nested nodes

We store child envelopes inside `children` hash keyed by path.

Routing algorithm:
- if target_path == envelope["path"] -> deliver to current
- else, find matching child envelope by key in children and recurse
- v0.1: only exact match lookup by children[target_path]

## Runtime
Responsibilities:
- locate root component class by envelope["root"]
- route msg to target node (by path)
- apply reducer
- execute effects loop
- re-render appropriate subtree
- return new envelope + rendered html

```rb
# lib/view_component_reducible/runtime.rb
module ViewComponentReducible
  class Runtime
    MAX_EFFECT_STEPS = 8

    def call(envelope:, msg:, target_path:, controller:)
      root_klass = ViewComponentReducible.registry.fetch(envelope["root"])
      new_env = deep_dup(envelope)

      new_env = dispatch_to_path(root_klass, new_env, msg, target_path, controller)

      html = render_root(root_klass, new_env, controller)
      [new_env, html]
    end

    private

    def dispatch_to_path(root_klass, env, msg, target_path, controller)
      if target_path == env["path"]
        apply_reducer(root_klass, env, msg, controller)
      else
        child = env["children"].fetch(target_path) { raise KeyError, "Unknown path: #{target_path}" }
        # NOTE: v0.1 assumes child component class can be derived from child["root"] or stored in child["root"]
        child_klass = ViewComponentReducible.registry.fetch(child["root"])
        env["children"][target_path] = dispatch_to_path(child_klass, child, msg, target_path, controller)
        env
      end
    end

    def apply_reducer(component_klass, env, msg, controller)
      component = component_klass.new
      schema = component_klass.vcr_state_schema
      data, meta = schema.build(env["data"], env["meta"])
      state = { "data" => data, "meta" => meta } # v0: keep plain hash

      new_state, effects = component.reduce(state, msg)
      env["data"] = new_state["data"]
      env["meta"] = new_state["meta"]

      run_effects(component_klass, env, effects, controller)
    end

    def run_effects(component_klass, env, effects, controller)
      return env if effects.nil? || effects.empty?

      effects_queue = effects.dup
      steps = 0

      while (eff = effects_queue.shift)
        steps += 1
        raise "Too many effect steps" if steps > MAX_EFFECT_STEPS

        follow_msg = eff.call(controller: controller, envelope: env)
        next unless follow_msg

        component = component_klass.new
        schema = component_klass.vcr_state_schema
        data, meta = schema.build(env["data"], env["meta"])
        state = { "data" => data, "meta" => meta }

        new_state, new_effects = component.reduce(state, follow_msg)
        env["data"] = new_state["data"]
        env["meta"] = new_state["meta"]
        effects_queue.concat(Array(new_effects))
      end

      env
    end

    def render_root(root_klass, env, controller)
      # v0.1: render whole root component
      # Provide env/state to component via assigns
      controller.view_context.render(root_klass.new(vcr_envelope: env))
    end

    def deep_dup(obj)
      Marshal.load(Marshal.dump(obj))
    end
  end
end
```

v0.1 simplification: render the whole root HTML. Partial update can be added later (Turbo Frame / data-target replacement).

