# frozen_string_literal: true

require 'active_support'
require 'active_support/message_verifier'

module ViewComponentReducible
  module Adapter
    # Hidden field adapter using signed payloads.
    class HiddenField < Base
      # @return [ActiveSupport::MessageVerifier]
      def verifier
        @verifier ||= ActiveSupport::MessageVerifier.new(@secret, digest: 'SHA256', serializer: JSON)
      end

      # @param envelope [Hash]
      # @param request [ActionDispatch::Request]
      # @return [String]
      def dump(envelope, request: nil)
        _ = request
        verifier.generate(envelope)
      end

      # @param request [ActionDispatch::Request]
      # @return [Hash]
      def load(request:)
        signed = request.params.fetch('vcr_state')
        verifier.verify(signed)
      end
    end
  end
end
