# frozen_string_literal: true

module ViewComponentReducible
  module State
    # State schema for defining default fields and building state payloads.
    class Schema
      Field = Struct.new(:name, :default, keyword_init: true)

      def initialize
        @fields = []
        @data_class = nil
        @data_class_fields = nil
      end

      # Add a field definition.
      # @param name [Symbol]
      # @param default [Object, #call]
      # @return [void]
      def add_field(name, default:)
        @fields << Field.new(name:, default:)
      end

      # @return [Class]
      def data_class
        field_names = @fields.map(&:name)
        return @data_class if @data_class && @data_class_fields == field_names

        defaults_proc = -> { build({}) }
        @data_class_fields = field_names
        @data_class = Data.define(*field_names) do
          def [](key)
            to_h[key.to_sym]
          end

          define_method(:with_defaults) do
            defaults = defaults_proc.call.transform_keys(&:to_sym)
            self.class.new(**defaults)
          end
        end
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

      # Build a Data object from input payloads.
      # @param state_hash [Hash]
      # @return [Data]
      def build_data(state_hash)
        data = build(state_hash)
        data_class.new(**data.transform_keys(&:to_sym))
      end

      # Build default state hashes.
      # @return [Hash{String=>Object}]
      def defaults
        build({})
      end
    end
  end
end
