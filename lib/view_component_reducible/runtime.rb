# frozen_string_literal: true

module ViewComponentReducible
  # Core runtime for dispatching messages and rendering components.
  class Runtime
    MAX_EFFECT_STEPS = 8

    # @param envelope [Hash]
    # @param msg [ViewComponentReducible::Msg]
    # @param target_path [String]
    # @param controller [ActionController::Base]
    # @return [Array<Hash, String>] [new_envelope, html]
    def call(envelope:, msg:, target_path:, controller:)
      root_klass = ViewComponentReducible.registry.fetch(envelope['root'])
      new_env = deep_dup(envelope)

      new_env = dispatch_to_path(root_klass, new_env, msg, target_path, controller)
      html = render_root(root_klass, new_env, controller)
      [new_env, html]
    end

    # Render HTML for a specific path after state updates.
    # @param envelope [Hash]
    # @param target_path [String]
    # @param controller [ActionController::Base]
    # @return [String]
    def render_target(envelope:, target_path:, controller:)
      root_klass = ViewComponentReducible.registry.fetch(envelope['root'])
      component_klass, env = find_env_and_class(root_klass, envelope, target_path)
      controller.view_context.render(component_klass.new(vcr_envelope: env))
    end

    private

    def dispatch_to_path(root_klass, env, msg, target_path, controller)
      if target_path == env['path']
        apply_reducer(root_klass, env, msg, controller)
      else
        child = env['children'].fetch(target_path) { raise KeyError, "Unknown path: #{target_path}" }
        child_klass = ViewComponentReducible.registry.fetch(child['root'])
        env['children'][target_path] = dispatch_to_path(child_klass, child, msg, target_path, controller)
        env
      end
    end

    def apply_reducer(component_klass, env, msg, controller)
      component = component_klass.new(vcr_envelope: env)
      schema = component_klass.vcr_state_schema
      state = schema.build(env['data'])

      new_state, effects = component.reduce(state, msg)
      env['data'] = new_state

      run_effects(component_klass, env, effects, controller)
    end

    def run_effects(component_klass, env, effects, controller)
      return env if effects.nil? || effects.empty?

      effects_queue = effects.dup
      steps = 0

      while (eff = effects_queue.shift)
        steps += 1
        raise 'Too many effect steps' if steps > MAX_EFFECT_STEPS

        follow_msg = eff.call(controller: controller, envelope: env)
        next unless follow_msg

        component = component_klass.new(vcr_envelope: env)
        schema = component_klass.vcr_state_schema
        state = schema.build(env['data'])

        new_state, new_effects = component.reduce(state, follow_msg)
        env['data'] = new_state
        effects_queue.concat(Array(new_effects))
      end

      env
    end

    def render_root(root_klass, env, controller)
      controller.view_context.render(root_klass.new(vcr_envelope: env))
    end

    def find_env_and_class(component_klass, env, target_path)
      return [component_klass, env] if target_path == env['path']

      child = env['children'].fetch(target_path) { raise KeyError, "Unknown path: #{target_path}" }
      child_klass = ViewComponentReducible.registry.fetch(child['root'])
      find_env_and_class(child_klass, child, target_path)
    end

    def deep_dup(obj)
      Marshal.load(Marshal.dump(obj))
    end
  end
end
