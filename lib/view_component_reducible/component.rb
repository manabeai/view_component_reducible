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
    # @return [String, nil]
    attr_reader :vcr_state_token

    # @param vcr_envelope [Hash, nil]
    # @param vcr_state_token [String, nil]
    def initialize(vcr_envelope: nil, vcr_state_token: nil, **kwargs)
      @vcr_envelope = vcr_envelope
      @vcr_state_token = vcr_state_token
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

    # Render component markup wrapped in a VCR boundary when available.
    # @param view_context [ActionView::Base]
    # @return [String]
    def render_in(view_context, &block)
      rendered = super
      path = vcr_envelope && vcr_envelope["path"]
      return rendered if path.nil? || path.to_s.empty?

      view_context.content_tag(:div, rendered, data: { vcr_path: path })
    end

    module ClassMethods
      # Stable component identifier for envelopes.
      # @return [String]
      def vcr_id
        component_name = name.to_s
        return "anonymous_component_#{object_id}" if component_name.empty?

        return component_name.demodulize.underscore if component_name.respond_to?(:demodulize)

        component_name
      end
    end
  end
end
