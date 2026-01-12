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
      state = schema.build_data(env['data'])

      reducer_result = component.reduce(state, msg)
      reduced_state, reducer_effects = case reducer_result
                                       in state_only unless reducer_result.is_a?(Array)
                                         [state_only, []]
                                       in [state_only]
                                         [state_only, []]
                                       in [state_only, *effects]
                                         [state_only, effects]
                                       end
      env['data'] = normalize_state(reduced_state, schema)
      effects = normalize_effects(reducer_effects) + normalize_effects(build_effects(component, schema, env['data'],
                                                                                     msg))

      run_effects(component_klass, env, effects, controller)
    end

    def run_effects(component_klass, env, effects, controller)
      effects_queue = normalize_effects(effects).dup
      return env if effects_queue.empty?

      steps = 0

      while (eff = effects_queue.shift)
        steps += 1
        raise 'Too many effect steps' if steps > MAX_EFFECT_STEPS

        follow_msg = resolve_effect_msg(eff, controller, env)
        next unless follow_msg
        raise ArgumentError, 'Effect must return a Msg' unless follow_msg.is_a?(Msg)

        component = component_klass.new(vcr_envelope: env)
        schema = component_klass.vcr_state_schema
        state = schema.build_data(env['data'])

        reducer_result = component.reduce(state, follow_msg)
        reduced_state, reducer_effects = case reducer_result
                                         in state_only unless reducer_result.is_a?(Array)
                                           [state_only, []]
                                         in [state_only]
                                           [state_only, []]
                                         in [state_only, *effects]
                                           [state_only, effects]
                                         end
        env['data'] = normalize_state(reduced_state, schema)
        new_effects = normalize_effects(reducer_effects) + normalize_effects(build_effects(component, schema,
                                                                                           env['data'], follow_msg))
        effects_queue.concat(new_effects)
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

    def normalize_state(state, schema)
      if state.is_a?(schema.data_class)
        state.to_h.transform_keys(&:to_s)
      elsif state.is_a?(Hash)
        schema.build(state)
      else
        raise ArgumentError, "Reducer must return a Hash or #{schema.data_class}"
      end
    end

    def build_effects(component, schema, state_hash, msg)
      return [] unless component.respond_to?(:effects)

      state = schema.build_data(state_hash)
      Array(component.effects(state, msg))
    end

    def normalize_effects(effects)
      Array(effects).compact
    end

    def resolve_effect_msg(effect, controller, env)
      return effect if effect.is_a?(Msg)
      return effect.call(controller: controller, envelope: env) if effect.respond_to?(:call)

      raise ArgumentError, 'Effect must respond to #call or be a Msg'
    end

    def deep_dup(obj)
      Marshal.load(Marshal.dump(obj))
    end
  end
end
