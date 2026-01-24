# frozen_string_literal: true

require 'json'
require 'rack/mock'

module ViewComponentReducible
  # Helpers for request specs hitting the VCR dispatch endpoint.
  module RequestSpecHelpers
    # Build an initial envelope for a component.
    # @param component [Class]
    # @param path [String]
    # @return [Hash]
    def vcr_initial_envelope(component, path: 'root')
      ViewComponentReducible::State::Envelope.initial(component, path: path)
    end

    # Build a signed state token for an envelope.
    # @param envelope [Hash]
    # @param adapter_class [Class]
    # @param session [Hash]
    # @return [String]
    def vcr_signed_state(envelope, adapter_class: ViewComponentReducible::Adapter::HiddenField, session: nil)
      adapter = ViewComponentReducible.config.adapter_for(nil, adapter_class: adapter_class)
      request = vcr_build_request(session)
      adapter.dump(envelope, request: request)
    end

    # Dispatch a message to the VCR endpoint.
    # @param type [String, Symbol]
    # @param options [Hash]
    # @option options [Hash, String, nil] :payload
    # @option options [String, nil] :target_path
    # @option options [Class, nil] :component
    # @option options [Hash, nil] :envelope
    # @option options [String] :path
    # @option options [String, nil] :state
    # @option options [Class] :adapter_class
    # @option options [String] :url
    # @option options [Hash] :headers
    # @option options [Hash, nil] :session
    # @option options [Hash] :params
    # @option options [Boolean] :partial
    # @return [void]
    def vcr_dispatch(type:, **options)
      payload = options.fetch(:payload, nil)
      target_path = options.fetch(:target_path, nil)
      component = options.fetch(:component, nil)
      envelope = options.fetch(:envelope, nil)
      path = options.fetch(:path, 'root')
      state = options.fetch(:state, nil)
      adapter_class = options.fetch(:adapter_class, ViewComponentReducible::Adapter::HiddenField)
      url = options.fetch(:url, '/vcr/dispatch')
      headers = options.fetch(:headers, {})
      session = options.fetch(:session, nil)
      params = options.fetch(:params, {})
      partial = options.fetch(:partial, false)

      resolved_envelope = envelope || (component ? vcr_initial_envelope(component, path: path) : nil)
      resolved_session = session || {}
      resolved_state = state || vcr_signed_state(
        resolved_envelope,
        adapter_class: adapter_class,
        session: resolved_session
      )
      resolved_target = target_path || resolved_envelope&.fetch('path', 'root') || 'root'
      state_param = adapter_class.state_param_name
      msg_payload = payload.is_a?(String) ? payload : JSON.generate(payload || {})
      dispatch_params = {
        state_param => resolved_state,
        'vcr_msg_type' => type,
        'vcr_msg_payload' => msg_payload,
        'vcr_target_path' => resolved_target
      }
      dispatch_params['vcr_partial'] = '1' if partial
      dispatch_params.merge!(params)

      resolved_headers = headers.dup
      resolved_headers['rack.session'] = resolved_session if adapter_class == ViewComponentReducible::Adapter::Session

      post(url, params: dispatch_params, headers: resolved_headers)
    end

    private

    def vcr_build_request(session)
      env = Rack::MockRequest.env_for('/')
      env['rack.session'] = session || {}
      ActionDispatch::Request.new(env)
    end
  end
end
