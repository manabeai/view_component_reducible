# frozen_string_literal: true

class BookingFlexibleComponent < ViewComponent::Base
  include ViewComponentReducible::Component

  state do
    field :selected_days, default: -> { [] }
    field :selected_times, default: -> { [] }
    field :selected_staff_ids, default: -> { [] }
    field :available_days, default: -> { BookingFlexibleComponent.available_days }
    field :available_times, default: -> { BookingFlexibleComponent.available_times }
    field :available_staff_ids, default: -> { BookingFlexibleComponent.available_staff_ids }
    field :phase, default: "multi"
    field :final_day, default: nil
    field :final_time, default: nil
    field :final_staff_id, default: nil
  end

  def reduce(state, msg)
    case msg
    in { type: :toggle_day, payload: payload }
      selected_days = toggle_value(state.selected_days, normalize_day(payload.day))
      apply_availability(state.with(selected_days: selected_days))

    in { type: :toggle_time, payload: payload }
      selected_times = toggle_value(state.selected_times, payload.time.to_s)
      apply_availability(state.with(selected_times: selected_times))

    in { type: :toggle_staff, payload: payload }
      selected_staff_ids = toggle_value(state.selected_staff_ids, payload.staff_id.to_i)
      apply_availability(state.with(selected_staff_ids: selected_staff_ids))

    in { type: :go_next }
      return state unless ready_for_final?(state)

      state.with(phase: "single", final_day: nil, final_time: nil, final_staff_id: nil)

    in { type: :back_to_multi }
      state.with(phase: "multi")

    in { type: :select_final_day, payload: payload }
      state.with(final_day: normalize_day(payload.day))

    in { type: :select_final_time, payload: payload }
      state.with(final_time: payload.time.to_s)

    in { type: :select_final_staff, payload: payload }
      state.with(final_staff_id: payload.staff_id.to_i)

    else
      state
    end
  end

  def available_staff
    Staff.where(id: state.available_staff_ids).order(:name)
  end

  def selected_staff
    Staff.where(id: state.selected_staff_ids).order(:name)
  end

  def phase_one?
    state.phase == "multi"
  end

  def phase_two?
    state.phase == "single"
  end

  def days_for_phase
    phase_two? ? state.selected_days : state.available_days
  end

  def times_for_phase
    phase_two? ? state.selected_times : state.available_times
  end

  def staff_for_phase
    ids = phase_two? ? state.selected_staff_ids : state.available_staff_ids
    Staff.where(id: ids).order(:name)
  end

  def day_label(day_key)
    date = Date.parse(day_key.to_s)
    "#{date.month}/#{date.day}"
  rescue Date::Error
    day_key.to_s
  end

  def weekday_label(day_key)
    date = Date.parse(day_key.to_s)
    %w[日 月 火 水 木 金 土][date.wday]
  rescue Date::Error
    "-"
  end

  def ready_for_final?(current_state = state)
    current_state.selected_days.any? && current_state.selected_times.any? && current_state.selected_staff_ids.any?
  end

  private

  def apply_availability(current_state)
    days = self.class.available_days(
      selected_times: current_state.selected_times,
      selected_staff_ids: current_state.selected_staff_ids
    )
    times = self.class.available_times(
      selected_days: current_state.selected_days,
      selected_staff_ids: current_state.selected_staff_ids
    )
    staff_ids = self.class.available_staff_ids(
      selected_days: current_state.selected_days,
      selected_times: current_state.selected_times
    )

    current_state.with(
      available_days: days,
      available_times: times,
      available_staff_ids: staff_ids,
      selected_days: current_state.selected_days & days,
      selected_times: current_state.selected_times & times,
      selected_staff_ids: current_state.selected_staff_ids & staff_ids
    )
  end

  def toggle_value(values, value)
    return values if value.nil?
    return values - [value] if values.include?(value)

    values + [value]
  end

  def normalize_day(value)
    Date.parse(value.to_s).iso8601
  rescue Date::Error
    value.to_s
  end

  class << self
    def available_days(selected_times: [], selected_staff_ids: [])
      slots = filtered_slots(selected_times:, selected_staff_ids:)
      slots.map(&:day_key).compact.uniq.sort
    end

    def available_times(selected_days: [], selected_staff_ids: [])
      slots = filtered_slots(selected_days:, selected_staff_ids:)
      slots.map(&:time_label).compact.uniq.sort
    end

    def available_staff_ids(selected_days: [], selected_times: [])
      slots = filtered_slots(selected_days:, selected_times:)
      slots.map(&:staff_id).compact.uniq.sort
    end

    private

    def filtered_slots(selected_days: [], selected_times: [], selected_staff_ids: [])
      slots = TimeSlot.includes(:staff).to_a

      if selected_staff_ids.any?
        ids = selected_staff_ids.map(&:to_i)
        slots = slots.select { |slot| ids.include?(slot.staff_id) }
      end

      if selected_days.any?
        day_keys = selected_days.map(&:to_s)
        slots = slots.select { |slot| day_keys.include?(slot.day_key.to_s) }
      end

      if selected_times.any?
        time_labels = selected_times.map(&:to_s)
        slots = slots.select { |slot| time_labels.include?(slot.time_label.to_s) }
      end

      slots
    end
  end
end
