# frozen_string_literal: true

module ViewComponentReducible
  module State
    # State schema for defining default fields and building state payloads.
    class Schema
      Field = Struct.new(:name, :default, :kind, keyword_init: true) # kind: :data or :meta

      def initialize
        @fields = []
      end

      # Add a field definition.
      # @param name [Symbol]
      # @param default [Object, #call]
      # @param kind [Symbol] :data or :meta
      # @return [void]
      def add_field(name, default:, kind:)
        @fields << Field.new(name:, default:, kind:)
      end

      # Build state hashes from input payloads.
      # @param data_hash [Hash]
      # @param meta_hash [Hash]
      # @return [Array<Hash{String=>Object}>] [data, meta]
      def build(data_hash, meta_hash)
        data = {}
        meta = {}
        @fields.each do |field|
          src = (field.kind == :meta ? meta_hash : data_hash) || {}
          value = if src.key?(field.name.to_s)
                    src[field.name.to_s]
                  elsif src.key?(field.name)
                    src[field.name]
                  end
          value = field.default.call if value.nil? && field.default.respond_to?(:call)
          value = field.default if value.nil? && !field.default.respond_to?(:call)

          if field.kind == :meta
            meta[field.name.to_s] = value
          else
            data[field.name.to_s] = value
          end
        end
        [data, meta]
      end

      # Build default state hashes.
      # @return [Array<Hash{String=>Object}>] [data, meta]
      def defaults
        build({}, {})
      end
    end
  end
end
