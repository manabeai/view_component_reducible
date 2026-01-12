# frozen_string_literal: true

module ViewComponentReducible
  module Adapter
    # Base adapter interface for envelope serialization.
    class Base
      # @param secret [String]
      # @param _kwargs [Hash]
      def initialize(secret:, **_kwargs)
        @secret = secret
      end

      # Encode envelope to a client-safe token.
      # @param envelope [Hash]
      # @param request [ActionDispatch::Request]
      # @return [String]
      def dump(envelope, request:)
        raise NotImplementedError
      end

      # Load envelope from a request.
      # @param request [ActionDispatch::Request]
      # @return [Hash]
      def load(request:)
        raise NotImplementedError
      end
    end
  end
end
