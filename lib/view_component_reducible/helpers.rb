# frozen_string_literal: true

require 'json'
require 'digest'

module ViewComponentReducible
  # View helpers for dispatching messages to the VCR endpoint.
  module Helpers
    include DebugHelpers
    include DispatchHelpers
    # Wrap component markup with a boundary for partial updates.
    # @param path [String]
    # @yield block for component content
    # @return [String]
    def vcr_boundary(path:, &block)
      content_tag(:div, capture(&block), data: { vcr_path: path })
    end

    # Build a dispatch button form with hidden fields for the VCR endpoint.
    # @param state [String, nil] signed state token (defaults to current component token)
    # @param type [String]
    # @param payload [Hash, String, nil]
    # @param target_path [String, nil]
    # @param transition [Boolean]
    # @param url [String]
    # @param button_attrs [Hash]
    # @yield block for the form body (e.g., submit button)
    # @return [String]
    def vcr_button_to(label = nil, type:, payload: nil, **options, &block)
      msg_payload = payload || {}
      payload = msg_payload.is_a?(String) ? msg_payload : JSON.generate(msg_payload)
      resolved_state = options.fetch(:state, nil) || instance_variable_get(:@vcr_state_token)
      target_path = options.fetch(:target_path, nil)
      resolved_target = target_path || vcr_envelope_path || instance_variable_get(:@vcr_current_path) || 'root'
      component_context = instance_variable_defined?(:@vcr_current_path) || !vcr_envelope_path.nil?
      if resolved_state.nil? && !component_context
        raise ArgumentError, 'vcr_state is missing. Pass state: or render inside a component.'
      end

      resolved_state = '' if resolved_state.nil?
      state_param = ViewComponentReducible.config.adapter.state_param_name
      button_body = block_given? ? capture(&block) : label
      raise ArgumentError, 'vcr_button_to requires a label or block.' if button_body.nil?

      button_attrs = options.fetch(:button_attrs, {})
      if options.fetch(:transition, false)
        button_attrs = button_attrs.merge(
          data: (button_attrs[:data] || {}).merge(vcr_transition: true)
        )
      end
      source_label = button_attrs.dig(:data, :vcr_source) || type.to_s
      source_id = Digest::SHA256.hexdigest("#{type}:#{payload}")
      button_attrs = button_attrs.merge(
        data: (button_attrs[:data] || {}).merge(vcr_source: source_label, vcr_source_id: source_id)
      )
      url = options.fetch(:url, '/vcr/dispatch')

      form_tag(url, method: :post, data: { vcr_form: true, vcr_state_param: state_param }) do
        body = [
          hidden_field_tag(state_param, resolved_state),
          hidden_field_tag('vcr_msg_type', type),
          hidden_field_tag('vcr_msg_payload', payload),
          hidden_field_tag('vcr_target_path', resolved_target),
          content_tag(:button, button_body, { type: 'submit' }.merge(button_attrs))
        ]
        safe_join(body)
      end
    end

    # Backward compatibility alias.
    # @deprecated Use vcr_button_to instead.
    def vcr_dispatch_form(...)
      vcr_button_to(...)
    end

    def vcr_envelope_path
      return unless respond_to?(:vcr_envelope) && vcr_envelope

      vcr_envelope['path']
    end
  end
end
