# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    envelope = ViewComponentReducible::State::Envelope.initial(CounterComponent)
    adapter = ViewComponentReducible.config.adapter_for(self)
    @vcr_state_token = adapter.dump(envelope, request: request)
    @component = CounterComponent.new(vcr_envelope: envelope, vcr_state_token: @vcr_state_token)
  end
end
