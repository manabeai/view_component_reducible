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
      new_state = state.with(
        count: state.count + 1,
        last_updated_at: Time.current
      )
      [new_state, []]
    in { type: :decrement }
      next_count = [state.count - 1, 0].max
      new_state = state.with(
        count: next_count,
        last_updated_at: Time.current
      )
      [new_state, []]
    in { type: :reset }
      new_state = state.with(count: 0, last_updated_at: nil)
      [new_state, []]
    else
      [state, []]
    end
  end
end
