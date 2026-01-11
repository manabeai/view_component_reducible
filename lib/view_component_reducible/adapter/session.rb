# frozen_string_literal: true

require 'active_support'
require 'active_support/message_verifier'
require 'securerandom'

module ViewComponentReducible
  module Adapter
    # Session adapter storing envelope in server session.
    class Session < Base
      # @return [ActiveSupport::MessageVerifier]
      def verifier
        @verifier ||= ActiveSupport::MessageVerifier.new(@secret, digest: 'SHA256', serializer: JSON)
      end

      # @param envelope [Hash]
      # @param request [ActionDispatch::Request]
      # @return [String]
      def dump(envelope, request:)
        key = SecureRandom.hex(16)
        request.session["vcr:#{key}"] = envelope
        verifier.generate({ 'k' => key })
      end

      # @param request [ActionDispatch::Request]
      # @return [Hash]
      def load(request:)
        signed = request.params.fetch('vcr_state')
        payload = verifier.verify(signed)
        key = payload.fetch('k')
        request.session.fetch("vcr:#{key}")
      end
    end
  end
end
