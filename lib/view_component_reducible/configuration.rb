# frozen_string_literal: true

module ViewComponentReducible
  # Global configuration for adapter and secrets.
  class Configuration
    # @return [Class]
    attr_accessor :adapter, :secret, :redis, :redis_url, :redis_ttl, :redis_namespace

    def initialize
      @adapter = Adapter::Session
      @secret = nil
      @redis = nil
      @redis_url = nil
      @redis_ttl = nil
      @redis_namespace = nil
    end

    # Build adapter instance for a controller request.
    # @param controller [ActionController::Base]
    # @param adapter_class [Class, nil]
    # @return [ViewComponentReducible::Adapter::Base]
    def adapter_for(_controller, adapter_class: nil)
      resolved_secret = secret || default_secret
      raise 'ViewComponentReducible secret is missing' if resolved_secret.nil?

      kwargs = { secret: resolved_secret }
      kwargs[:redis] = redis if redis
      kwargs[:redis_url] = redis_url if redis_url
      kwargs[:redis_ttl] = redis_ttl unless redis_ttl.nil?
      kwargs[:redis_namespace] = redis_namespace if redis_namespace

      (adapter_class || adapter).new(**kwargs)
    end

    private

    def default_secret
      return Rails.application.secret_key_base if defined?(Rails) && Rails.respond_to?(:application)

      nil
    end
  end
end
