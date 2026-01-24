# frozen_string_literal: true

ViewComponentReducible.configure do |config|
  adapter_name = ENV.fetch("VCR_ADAPTER", "redis")
  config.adapter = case adapter_name
                   when "hidden_field"
                     ViewComponentReducible::Adapter::HiddenField
                   when "session"
                     ViewComponentReducible::Adapter::Session
                   else
                     ViewComponentReducible::Adapter::Redis
                   end
  config.secret = Rails.application.secret_key_base
  config.redis_url = ENV.fetch("REDIS_URL", "redis://localhost:6379/1")
end
