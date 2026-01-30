# frozen_string_literal: true

class CounterComponent < ViewComponent::Base
  include ViewComponentReducible::Component

  state do
    field :count, default: 0
  end

  def reduce(state, msg)
    case msg
    in { type: :increment }
      state.with(count: state.count + 1)
    in { type: :decrement }
      state.with(count: state.count - 1)
    end
  end
end
