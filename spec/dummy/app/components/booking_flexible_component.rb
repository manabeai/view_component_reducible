# frozen_string_literal: true

class BookingFlexibleComponent < ViewComponent::Base
  include ViewComponentReducible::Component

  state do
    field :selected_days, default: -> { [] }
    field :selected_times, default: -> { [] }
    field :selected_staff_ids, default: -> { [] }
    field :desired_days, default: -> { [] }
    field :desired_times, default: -> { [] }
    field :desired_staff_ids, default: -> { [] }
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
      desired_days = toggle_value(state.desired_days, normalize_day(payload.day))
      apply_availability(state.with(desired_days: desired_days))

    in { type: :toggle_time, payload: payload }
      desired_times = toggle_value(state.desired_times, payload.time.to_s)
      apply_availability(state.with(desired_times: desired_times))

    in { type: :toggle_staff, payload: payload }
      desired_staff_ids = toggle_value(state.desired_staff_ids, payload.staff_id.to_i)
      apply_availability(state.with(desired_staff_ids: desired_staff_ids))

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
    phase_two? ? state.selected_days : all_days
  end

  def times_for_phase
    phase_two? ? state.selected_times : all_times
  end

  def staff_for_phase
    ids = phase_two? ? state.selected_staff_ids : all_staff_ids
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

  def all_days
    self.class.all_days
  end

  def all_times
    self.class.all_times
  end

  def all_staff_ids
    self.class.all_staff_ids
  end

  def available_day?(day_key)
    state.available_days.include?(day_key)
  end

  def available_time?(time_label)
    state.available_times.include?(time_label)
  end

  def available_staff?(staff_id)
    state.available_staff_ids.include?(staff_id)
  end

  def desired_day?(day_key)
    state.desired_days.include?(day_key)
  end

  def desired_time?(time_label)
    state.desired_times.include?(time_label)
  end

  def desired_staff?(staff_id)
    state.desired_staff_ids.include?(staff_id)
  end

  def ready_for_final?(current_state = state)
    current_state.selected_days.any? && current_state.selected_times.any? && current_state.selected_staff_ids.any?
  end

  private

  def apply_availability(current_state)
    recalc = recalculate_active(
      desired_days: current_state.desired_days,
      desired_times: current_state.desired_times,
      desired_staff_ids: current_state.desired_staff_ids
    )

    current_state.with(
      available_days: recalc[:available_days],
      available_times: recalc[:available_times],
      available_staff_ids: recalc[:available_staff_ids],
      selected_days: recalc[:active_days],
      selected_times: recalc[:active_times],
      selected_staff_ids: recalc[:active_staff_ids]
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

  def recalculate_active(desired_days:, desired_times:, desired_staff_ids:)
    active_days = desired_days
    active_times = desired_times
    active_staff_ids = desired_staff_ids
    available_days = []
    available_times = []
    available_staff_ids = []

    2.times do
      available_days = self.class.available_days(
        selected_times: active_times,
        selected_staff_ids: active_staff_ids
      )
      active_days = desired_days & available_days

      available_times = self.class.available_times(
        selected_days: active_days,
        selected_staff_ids: active_staff_ids
      )
      active_times = desired_times & available_times

      available_staff_ids = self.class.available_staff_ids(
        selected_days: active_days,
        selected_times: active_times
      )
      active_staff_ids = desired_staff_ids & available_staff_ids
    end

    {
      active_days: active_days,
      active_times: active_times,
      active_staff_ids: active_staff_ids,
      available_days: available_days,
      available_times: available_times,
      available_staff_ids: available_staff_ids
    }
  end

  class << self
    def all_days
      all_slots.map(&:day_key).compact.uniq.sort
    end

    def all_times
      all_slots.map(&:time_label).compact.uniq.sort
    end

    def all_staff_ids
      all_slots.map(&:staff_id).compact.uniq.sort
    end

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

    def all_slots
      TimeSlot.includes(:staff).to_a
    end

    def filtered_slots(selected_days: [], selected_times: [], selected_staff_ids: [])
      slots = all_slots

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
