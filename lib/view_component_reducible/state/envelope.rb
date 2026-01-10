# frozen_string_literal: true

module ViewComponentReducible
  module State
    # Envelope builder for initial state payloads.
    class Envelope
      # Build an initial envelope for a component.
      # @param root_component_klass [Class]
      # @param path [String]
      # @return [Hash{String=>Object}]
      def self.initial(root_component_klass, path: "root")
        schema = root_component_klass.vcr_state_schema
        data, meta = schema.defaults
        {
          "v" => 1,
          "root" => root_component_klass.vcr_id,
          "path" => path,
          "data" => data,
          "children" => {},
          "meta" => meta
        }
      end
    end
  end
end
