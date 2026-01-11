# frozen_string_literal: true

module ViewComponentReducible
  module State
    # DSL for defining state schemas on components.
    module DSL
      # Hook to extend class methods when included.
      # @param base [Class]
      # @return [void]
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        # Define a state schema for the component.
        # @yield DSL block to declare fields.
        # @return [void]
        def state(&block)
          schema = Schema.new
          dsl = Builder.new(schema)
          dsl.instance_eval(&block)
          @vcr_state_schema = schema

          define_singleton_method(:vcr_state_schema) { @vcr_state_schema }
        end
      end

      class Builder
        def initialize(schema) = (@schema = schema)

        # Define a state field.
        # @param name [Symbol]
        # @param default [Object, #call]
        # @return [void]
        def field(name, default:)
          @schema.add_field(name, default:)
        end
      end
    end
  end
end
