# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    envelope = ViewComponentReducible::State::Envelope.initial(MyFormComponent)
    adapter = ViewComponentReducible.config.adapter_for(self)
    @vcr_state_token = adapter.dump(envelope, request: request)
    @component = MyFormComponent.new(vcr_envelope: envelope, vcr_state_token: @vcr_state_token)
  end
end
