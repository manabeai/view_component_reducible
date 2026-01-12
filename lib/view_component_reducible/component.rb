# frozen_string_literal: true

require 'nokogiri'

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
    # @return [Hash{String=>Object}]
    def vcr_state
      return {} if vcr_envelope.nil?

      schema = self.class.vcr_state_schema
      schema.build(vcr_envelope['data'])
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
      ensure_vcr_state(view_context) if vcr_envelope.nil?

      rendered = super
      path = vcr_envelope && vcr_envelope['path']
      return rendered if path.nil? || path.to_s.empty?

      inject_vcr_path(rendered, path)
    end

    module ClassMethods
      # Stable component identifier for envelopes.
      # @return [String]
      def vcr_id
        name.to_s
      end
    end

    private

    def inject_vcr_path(rendered, path)
      fragment = Nokogiri::HTML::DocumentFragment.parse(rendered.to_s)
      root = fragment.children.find(&:element?)
      return rendered if root.nil?

      root['data-vcr-path'] = path
      html = fragment.to_html
      html.respond_to?(:html_safe) ? html.html_safe : html
    end

    def ensure_vcr_state(view_context)
      return unless view_context.respond_to?(:controller)

      controller = view_context.controller
      return unless controller.respond_to?(:request)

      envelope = State::Envelope.initial(self.class)
      adapter = ViewComponentReducible.config.adapter_for(controller)
      @vcr_state_token = adapter.dump(envelope, request: controller.request)
      @vcr_envelope = envelope
    end
  end
end
