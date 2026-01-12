# frozen_string_literal: true

class CounterComponent < ViewComponent::Base
  include ViewComponentReducible::Component

  state do
    field :count, default: 0
    field :last_updated_at, default: nil
  end

  def reduce(state, msg)
    case msg
    in { type: :increment }
      state.with(count: state.count + 1, last_updated_at: Time.current)
    in { type: :decrement, payload: _payload }
      state.with(count: [ state.count - 1, 0 ].max, last_updated_at: Time.current)
    in { type: :reset, payload: _payload }
      state.with_defaults
    end
  end
end
