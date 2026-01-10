# frozen_string_literal: true

require "json"

module ViewComponentReducible
  # View helpers for dispatching messages to the VCR endpoint.
  module Helpers
    # Build a dispatch form with hidden fields for the VCR endpoint.
    # @param state [String] signed state token
    # @param msg_type [String]
    # @param msg_payload [Hash, String]
    # @param target_path [String]
    # @param url [String]
    # @yield block for the form body (e.g., submit button)
    # @return [String]
    def vcr_dispatch_form(state:, msg_type:, msg_payload: {}, target_path: "root", url: "/vcr/dispatch", &block)
      payload = msg_payload.is_a?(String) ? msg_payload : JSON.generate(msg_payload)

      form_tag(url, method: :post) do
        body = [
          hidden_field_tag("vcr_state", state),
          hidden_field_tag("vcr_msg_type", msg_type),
          hidden_field_tag("vcr_msg_payload", payload),
          hidden_field_tag("vcr_target_path", target_path),
          (block_given? ? capture(&block) : "")
        ]
        safe_join(body)
      end
    end
  end
end
