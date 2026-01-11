# frozen_string_literal: true

class MyFormComponent < ViewComponent::Base
  include ViewComponentReducible::Component

  state do
    field :count, default: 0
    field :last_updated_at, default: nil
  end

  def reduce(state, msg)
    case msg
    in { type: :increment }
      state.with(count: state.count + 1, last_updated_at: Time.current)
    in { type: :decrement }
      state.with(count: [state.count - 1, 0].max, last_updated_at: Time.current)
    in { type: :reset }
      state.with_defaults
    end
  end
end
