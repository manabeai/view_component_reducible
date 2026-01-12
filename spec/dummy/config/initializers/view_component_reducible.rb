# frozen_string_literal: true

ViewComponentReducible.configure do |config|
  config.adapter = ViewComponentReducible::Adapter::HiddenField
  config.secret = Rails.application.secret_key_base
end

Rails.application.config.to_prepare do
  require_dependency "counter_component"
  require_dependency "booking_component"
  ViewComponentReducible.register(CounterComponent)
  ViewComponentReducible.register(BookingComponent)
end
