# frozen_string_literal: true

class BookingComponent < ViewComponent::Base
  include ViewComponentReducible::Component

  STAFF_OPTIONS = %w[Aki Mika Sora].freeze

  state do
    field :calendar_days, default: -> { BookingMockData.calendar_days }
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
      calendar_effect = build_calendar_effect
      effect = build_times_effect(payload.day.to_i)
      [
        state.with(selected_day: payload.day.to_i, selected_time: nil, selected_staff: nil, available_times: BookingMockData.base_times, available_staff: []),
        calendar_effect,
        effect
      ]

    in { type: :select_time, payload: payload }
      effect = build_staff_effect(payload.time)
      [state.with(selected_time: payload.time, selected_staff: nil, available_staff: BookingMockData.base_staff), effect]

    in { type: :times_loaded, payload: payload }
      state.with(available_times: payload.times || [])

    in { type: :staff_loaded, payload: payload }
      state.with(available_staff: payload.staff || [])

    in { type: :calendar_loaded, payload: payload }
      state.with(calendar_days: payload.days || [])

    in { type: :select_staff, payload: payload }
      state.with(selected_staff: payload.staff)
    end
  end

  def calendar_day_records
    BookingMockData.calendar_day_records(vcr_state.calendar_days)
  end

  def calendar_status_label(status)
    case status
    when "circle" then "◯"
    when "triangle" then "△"
    when "cross" then "×"
    else "-"
    end
  end

  def calendar_status_class(status)
    case status
    when "circle" then "text-red-500"
    when "triangle" then "text-yellow-500"
    when "cross" then "text-stone-500"
    else "text-stone-400"
    end
  end

  def calendar_day_button_class(day, status)
    base = "flex flex-col items-center rounded-xl border px-3 py-2 text-xs font-semibold"
    selected = "border-amber-500 bg-amber-100 text-amber-800"
    normal = "border-stone-200 bg-stone-50 text-stone-700 hover:bg-amber-50"
    disabled = "cursor-not-allowed border-stone-300 bg-stone-200 text-stone-600"
    state_class = if calendar_day_disabled?(status)
                    disabled
                  elsif vcr_state.selected_day == day
                    selected
                  else
                    normal
                  end
    [base, state_class].join(" ")
  end

  def calendar_day_disabled?(status)
    status == "cross"
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

  def build_calendar_effect
    days = BookingMockData.calendar_days

    lambda do |**_kwargs|
      ViewComponentReducible::Msg.build(type: "CalendarLoaded", payload: { days: days })
    end
  end
end

ViewComponentReducible.register(BookingComponent)
