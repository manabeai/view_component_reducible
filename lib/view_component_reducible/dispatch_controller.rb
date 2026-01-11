# frozen_string_literal: true

require 'action_controller'

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
  end
end
