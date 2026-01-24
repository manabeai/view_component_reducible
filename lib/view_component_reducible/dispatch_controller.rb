# frozen_string_literal: true

require 'action_controller'
require 'json'

module ViewComponentReducible
  # Rails controller entry for dispatch requests.
  class DispatchController < ActionController::Base
    protect_from_forgery with: :exception

    # @param adapter_class [Class]
    # @return [Class, nil]
    def self.vcr_adapter(adapter_class = nil)
      return @vcr_adapter if adapter_class.nil?

      @vcr_adapter = adapter_class
    end

    # @return [void]
    def call
      adapter_class = self.class.vcr_adapter || ViewComponentReducible.config.adapter
      adapter = ViewComponentReducible.config.adapter_for(self, adapter_class: adapter_class)
      envelope = adapter.load(request:)
      msg = ViewComponentReducible::Msg.from_params(params)
      target_path = params.fetch('vcr_target_path', envelope['path'])

      runtime = ViewComponentReducible::Runtime.new
      new_envelope, html = runtime.call(
        envelope:,
        msg:,
        target_path:,
        controller: self
      )

      signed = adapter.dump(new_envelope, request:)
      if debug_enabled?
        debug = debug_payload(envelope, new_envelope, msg, target_path, runtime.debug_chain)
        response.set_header('X-VCR-Debug', JSON.generate(debug))
      end
      if params['vcr_partial'] == '1'
        partial_html = runtime.render_target(envelope: new_envelope, target_path:, controller: self)
        response.set_header('X-VCR-State', signed)
        render html: partial_html, content_type: 'text/html'
      else
        render html: ViewComponentReducible::Dispatch.inject_state(html, signed), content_type: 'text/html'
      end
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      render status: 400, plain: 'Invalid state signature'
    end

    private

    def debug_enabled?
      request.headers['X-VCR-Debug'] == '1'
    end

    def debug_payload(envelope, new_envelope, msg, target_path, chain)
      before_env = find_env(envelope, target_path)
      after_env = find_env(new_envelope, target_path)
      changes = diff_state(before_env.fetch('data', {}), after_env.fetch('data', {}))
      payload = normalize_debug_payload(msg.payload)
      {
        'path' => target_path,
        'msg_type' => msg.type.to_s,
        **(payload.nil? ? {} : { 'payload' => payload }),
        'chain' => Array(chain),
        'changed_keys' => changes.keys,
        'changes' => changes,
        'state' => after_env.fetch('data', {})
      }
    end

    def diff_state(before_state, after_state)
      before_state ||= {}
      after_state ||= {}
      keys = (before_state.keys + after_state.keys).uniq
      keys.each_with_object({}) do |key, acc|
        before_value = before_state[key]
        after_value = after_state[key]
        next if before_value == after_value

        acc[key] = { 'from' => before_value, 'to' => after_value }
      end
    end

    def find_env(envelope, target_path)
      return envelope if envelope['path'] == target_path

      child = envelope.fetch('children', {}).fetch(target_path) { raise KeyError, "Unknown path: #{target_path}" }
      find_env(child, target_path)
    end

    def normalize_debug_payload(payload)
      return if payload.is_a?(ViewComponentReducible::Msg::Payload::Empty)

      payload.respond_to?(:to_h) ? payload.to_h : payload
    end
  end
end
