# frozen_string_literal: true

class BookingComponent < ViewComponent::Base
  include ViewComponentReducible::Component

  STAFF_OPTIONS = %w[Aki Mika Sora].freeze

  state do
    field :selected_day, default: nil
    field :selected_time, default: nil
    field :selected_staff, default: nil
  end

  def staff_options
    STAFF_OPTIONS
  end

  def reduce(state, msg)
    case msg
    in { type: :select_day, payload: }
      day = payload['day'] || payload[:day]
      state.with(selected_day: day.to_i, selected_time: nil, selected_staff: nil)
    in { type: :select_time, payload: }
      time = payload['time'] || payload[:time]
      state.with(selected_time: time, selected_staff: nil)
    in { type: :select_staff, payload: }
      staff = payload['staff'] || payload[:staff]
      state.with(selected_staff: staff)
    else
      state
    end
  end
end

ViewComponentReducible.register(BookingComponent)
