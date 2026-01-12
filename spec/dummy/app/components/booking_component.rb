# frozen_string_literal: true

class BookingComponent < ViewComponent::Base
  include ViewComponentReducible::Component

  STAFF_OPTIONS = %w[Aki Mika Sora].freeze

  state do
    field :selected_day, default: nil
    field :selected_time, default: nil
    field :selected_staff, default: nil
    field :available_times, default: []
    field :available_staff, default: []
  end

  def staff_options
    STAFF_OPTIONS
  end

  def reduce(state, msg)
    case msg
    in { type: :select_day, payload: payload }
      effect = build_times_effect(payload.day.to_i)
      [state.with(selected_day: payload.day.to_i, selected_time: nil, selected_staff: nil, available_times: BookingMockData.base_times, available_staff: []), effect]

    in { type: :select_time, payload: payload }
      effect = build_staff_effect(payload.time)
      [state.with(selected_time: payload.time, selected_staff: nil, available_staff: BookingMockData.base_staff), effect]

    in { type: :times_loaded, payload: payload }
      state.with(available_times: payload.times || [])

    in { type: :staff_loaded, payload: payload }
      state.with(available_staff: payload.staff || [])

    in { type: :select_staff, payload: payload }
      state.with(selected_staff: payload.staff)
    end
  end

  private

  def build_times_effect(day)
    times = BookingMockData.available_times

    lambda do |**_kwargs|
      ViewComponentReducible::Msg.build(type: "TimesLoaded", payload: { times: times })
    end
  end

  def build_staff_effect(time)
    staff = BookingMockData.available_staff(options: STAFF_OPTIONS)

    lambda do |**_kwargs|
      ViewComponentReducible::Msg.build(type: "StaffLoaded", payload: { staff: staff, time: time })
    end
  end
end

ViewComponentReducible.register(BookingComponent)
