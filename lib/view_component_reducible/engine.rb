# frozen_string_literal: true

require "rails/engine"

module ViewComponentReducible
  # Rails engine for mounting dispatch routes.
  class Engine < ::Rails::Engine
    isolate_namespace ViewComponentReducible

    routes.draw do
      post "/dispatch", to: "dispatch#call"
    end
  end
end
