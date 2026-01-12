# frozen_string_literal: true

ViewComponentReducible.configure do |config|
  config.adapter = ViewComponentReducible::Adapter::Redis
  config.secret = Rails.application.secret_key_base
  config.redis_url = ENV.fetch("REDIS_URL", "redis://localhost:6379/1")
end

Rails.application.config.to_prepare do
  require_dependency "counter_component"
  require_dependency "booking_component"
  ViewComponentReducible.register(CounterComponent)
  ViewComponentReducible.register(BookingComponent)
end
