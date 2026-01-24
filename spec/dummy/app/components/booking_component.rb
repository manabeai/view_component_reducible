# frozen_string_literal: true

class BookingComponent < ViewComponent::Base
  include ViewComponentReducible::Component

  # BookingMockData returns:
  # - calendar_days: Array<Hash> (day, date, weekday, status, year, month)
  # - calendar_day_records: Array<BookingMockData::Day>
  #   - BookingMockData::Day fields: day, date, weekday, status, year, month
  # - base_times: Array<String>
  # - base_staff: Array<String>
  # - available_times: Array<String>
  # - available_staff: Array<String>
  # - STAFF_OPTIONS: Array<String>
  CALENDAR_STATUS = {
    "circle" => ["◯", "rounded-full bg-emerald-100 px-2 py-0.5 text-emerald-700"],
    "triangle" => ["△", "rounded-full bg-yellow-100 px-2 py-0.5 text-yellow-700"],
    "cross" => ["×", "text-stone-500"]
  }.freeze

  state do
    field :calendar_days, default: -> { BookingMockData.calendar_days }
    field :selected_day, default: nil
    field :selected_time, default: nil
    field :selected_staff, default: nil
    field :available_times, default: []
    field :available_staff, default: []
  end

  def reduce(state, msg)
    case msg
    in { type: :select_day, payload: payload }
      return state if state.selected_day == payload.day.to_i
      
      calendar_effect = build_calendar_effect
      effect = build_times_effect(payload.day.to_i)
      [
        state.with(selected_day: payload.day.to_i, selected_time: nil, selected_staff: nil, available_times: BookingMockData.base_times, available_staff: []),
        calendar_effect,
        effect
      ]

    in { type: :select_time, payload: payload }
      return state if state.selected_time == payload.time

      effect = build_staff_effect(payload.time)
      [state.with(selected_time: payload.time, selected_staff: nil, available_staff: BookingMockData.base_staff), effect]

    in { type: :times_loaded, payload: payload }
      state.with(available_times: payload.times || [])

    in { type: :staff_loaded, payload: payload }
      state.with(available_staff: payload.staff || [])

    in { type: :calendar_loaded, payload: payload }
      state.with(calendar_days: payload.days || [])

    in { type: :select_staff, payload: payload }
      effect = build_select_staff_effect(payload.staff)
      [state, effect]

    in { type: :staff_selected, payload: payload }
      state.with(selected_staff: payload.staff)
    end
  end

  private

  def build_times_effect(day)
    times = BookingMockData.available_times(day: day)

    emit(:times_loaded, times: times)
  end

  def build_staff_effect(time)
    staff = BookingMockData.available_staff(options: BookingMockData::STAFF_OPTIONS, time: time)

    emit(:staff_loaded, staff: staff, time: time)
  end

  def build_select_staff_effect(staff)
    emit(:staff_selected, staff: staff)
  end

  def build_calendar_effect
    days = BookingMockData.calendar_days

    emit(:calendar_loaded, days: days)
  end

  public

  def staff_options
    BookingMockData::STAFF_OPTIONS
  end

  def calendar_day_records
    BookingMockData.calendar_day_records(state.calendar_days)
  end

  def calendar_day_summary(day)
    record = calendar_day_records.find { |item| item.day == day }
    return summary_label(nil) if record.nil? || record.year.nil? || record.month.nil?

    "#{record.year}年#{record.month}月#{record.day}日"
  end

  def summary_label(value, empty_label: "未選択")
    value.nil? || value == "" ? empty_label : value
  end

  def summary_class(value)
    value.nil? || value == "" ? "text-stone-300" : "text-stone-700"
  end

  def calendar_status_label(status)
    CALENDAR_STATUS.dig(status, 0) || "-"
  end

  def calendar_status_class(status)
    CALENDAR_STATUS.dig(status, 1) || "text-stone-400"
  end

  def calendar_day_button_class(day, status)
    base = "flex flex-col items-center rounded-xl border px-3 py-2 text-xs font-semibold"
    selected = "border-amber-500 bg-amber-100 text-amber-800"
    normal = "border-stone-200 bg-stone-50 text-stone-700 hover:bg-amber-50"
    disabled = "cursor-not-allowed border-stone-300 bg-stone-200 text-stone-600"
    state_class = if calendar_day_disabled?(status)
                    disabled
                  elsif state.selected_day == day
                    selected
                  else
                    normal
                  end
    [base, state_class].join(" ")
  end

  def calendar_day_disabled?(status)
    status == "cross"
  end
end

ViewComponentReducible.register(BookingComponent)
