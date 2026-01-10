# frozen_string_literal: true

module ViewComponentReducible
  # Include to enable the component state DSL and helpers.
  module Component
    # Hook to include DSL and class methods.
    # @param base [Class]
    # @return [void]
    def self.included(base)
      base.include(State::DSL)
      base.extend(ClassMethods)
    end

    # @return [Hash, nil]
    attr_reader :vcr_envelope

    # @param vcr_envelope [Hash, nil]
    def initialize(vcr_envelope: nil, **kwargs)
      @vcr_envelope = vcr_envelope
      return unless defined?(super)

      kwargs.empty? ? super() : super(**kwargs)
    end

    # Build state hash for rendering from the envelope.
    # @return [Hash{String=>Hash}]
    def vcr_state
      return { "data" => {}, "meta" => {} } if vcr_envelope.nil?

      schema = self.class.vcr_state_schema
      data, meta = schema.build(vcr_envelope["data"], vcr_envelope["meta"])
      { "data" => data, "meta" => meta }
    end

    # Optional DOM target id for updates.
    # @param path [String]
    # @return [String]
    def vcr_dom_id(path:)
      "vcr:#{self.class.vcr_id}:#{path}"
    end

    module ClassMethods
      # Stable component identifier for envelopes.
      # @return [String]
      def vcr_id
        name.to_s
      end
    end
  end
end
