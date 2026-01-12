# frozen_string_literal: true

ViewComponentReducible::Engine.routes.draw do
  post "/dispatch", to: "dispatch#call"
end
