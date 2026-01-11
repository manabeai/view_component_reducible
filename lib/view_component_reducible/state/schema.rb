# frozen_string_literal: true

module ViewComponentReducible
  module State
    # State schema for defining default fields and building state payloads.
    class Schema
      Field = Struct.new(:name, :default, keyword_init: true)

      def initialize
        @fields = []
      end

      # Add a field definition.
      # @param name [Symbol]
      # @param default [Object, #call]
      # @return [void]
      def add_field(name, default:)
        @fields << Field.new(name:, default:)
      end

      # Build state hashes from input payloads.
      # @param state_hash [Hash]
      # @return [Hash{String=>Object}]
      def build(state_hash)
        data = {}
        @fields.each do |field|
          src = state_hash || {}
          value = if src.key?(field.name.to_s)
                    src[field.name.to_s]
                  elsif src.key?(field.name)
                    src[field.name]
                  end
          value = field.default.call if value.nil? && field.default.respond_to?(:call)
          value = field.default if value.nil? && !field.default.respond_to?(:call)

          data[field.name.to_s] = value
        end
        data
      end

      # Build default state hashes.
      # @return [Hash{String=>Object}]
      def defaults
        build({})
      end
    end
  end
end
