# frozen_string_literal: true

ViewComponentReducible.configure do |config|
  config.adapter = ViewComponentReducible::Adapter::Session
  config.secret = Rails.application.secret_key_base
end

ViewComponentReducible.register(MyFormComponent)
