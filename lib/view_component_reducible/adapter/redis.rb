# frozen_string_literal: true

require 'active_support'
require 'active_support/message_verifier'
require 'securerandom'
require 'json'

module ViewComponentReducible
  module Adapter
    # Redis adapter storing envelope outside of the session.
    class Redis < Base
      DEFAULT_TTL = 900
      DEFAULT_NAMESPACE = 'vcr'

      def self.state_param_name
        'vcr_state_key'
      end

      # @param secret [String]
      # @param redis [Object, nil]
      # @param redis_url [String, nil]
      # @param redis_ttl [Integer, nil]
      # @param redis_namespace [String, nil]
      def initialize(secret:, redis: nil, redis_url: nil, redis_ttl: DEFAULT_TTL, redis_namespace: DEFAULT_NAMESPACE)
        super(secret:)
        @redis = redis || build_client(redis_url)
        @redis_ttl = redis_ttl
        @redis_namespace = redis_namespace
      end

      # @return [ActiveSupport::MessageVerifier]
      def verifier
        @verifier ||= ActiveSupport::MessageVerifier.new(@secret, digest: 'SHA256', serializer: JSON)
      end

      # @param envelope [Hash]
      # @param request [ActionDispatch::Request]
      # @return [String]
      def dump(envelope, request:)
        _ = request
        key = SecureRandom.hex(16)
        write(key, JSON.generate(envelope))
        verifier.generate({ 'k' => key })
      end

      # @param request [ActionDispatch::Request]
      # @return [Hash]
      def load(request:)
        signed = request.params.fetch(self.class.state_param_name)
        payload = verifier.verify(signed)
        key = payload.fetch('k')
        raw = @redis.get(redis_key(key))
        raise KeyError, "Missing envelope for #{key}" if raw.nil?

        JSON.parse(raw)
      end

      private

      def build_client(redis_url)
        require 'redis'
        return ::Redis.new if redis_url.nil? || redis_url == ''

        ::Redis.new(url: redis_url)
      rescue LoadError
        raise LoadError, 'Redis adapter requires the redis gem. Add `gem "redis"` to your bundle.'
      end

      def write(key, payload)
        if @redis_ttl
          @redis.setex(redis_key(key), @redis_ttl, payload)
        else
          @redis.set(redis_key(key), payload)
        end
      end

      def redis_key(key)
        "#{@redis_namespace}:#{key}"
      end
    end
  end
end
