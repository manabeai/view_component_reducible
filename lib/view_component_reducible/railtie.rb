# frozen_string_literal: true

require "rails/railtie"

module ViewComponentReducible
  # Railtie for wiring helpers into ActionView.
  class Railtie < ::Rails::Railtie
    initializer "view_component_reducible.helpers" do
      ActiveSupport.on_load(:action_view) do
        include ViewComponentReducible::Helpers
      end
    end
  end
end
