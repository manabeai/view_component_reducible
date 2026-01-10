# frozen_string_literal: true

class MyFormComponent < ViewComponent::Base
  include ViewComponentReducible::Component

  attr_reader :vcr_state_token

  state do
    field :name, default: ""
    meta :loading, default: false
  end

  def initialize(vcr_envelope:, vcr_state_token:)
    @vcr_envelope = vcr_envelope
    @vcr_state_token = vcr_state_token
    super()
  end

  def reduce(state, msg)
    case msg.type
    when "ClickedSave"
      new_state = state.merge("meta" => state["meta"].merge("loading" => true))
      [new_state, []]
    else
      [state, []]
    end
  end
end
