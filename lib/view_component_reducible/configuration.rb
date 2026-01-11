# frozen_string_literal: true

module ViewComponentReducible
  # Global configuration for adapter and secrets.
  class Configuration
    # @return [Class]
    attr_accessor :adapter, :secret

    def initialize
      @adapter = Adapter::Session
      @secret = nil
    end

    # Build adapter instance for a controller request.
    # @param controller [ActionController::Base]
    # @param adapter_class [Class, nil]
    # @return [ViewComponentReducible::Adapter::Base]
    def adapter_for(_controller, adapter_class: nil)
      resolved_secret = secret || default_secret
      raise 'ViewComponentReducible secret is missing' if resolved_secret.nil?

      (adapter_class || adapter).new(secret: resolved_secret)
    end

    private

    def default_secret
      return Rails.application.secret_key_base if defined?(Rails) && Rails.respond_to?(:application)

      nil
    end
  end
end
