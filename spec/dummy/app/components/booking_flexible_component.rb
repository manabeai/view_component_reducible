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
    field :confirmed_at, default: nil
  end

  def reduce(state, msg)
    case msg
    in { type: :toggle_day, payload: payload }
      desired_days = toggle_value(state.desired_days, normalize_day(payload.day))
      next_state = state.with(desired_days: desired_days)
      [next_state, build_availability_effect_from(next_state)]

    in { type: :toggle_time, payload: payload }
      desired_times = toggle_value(state.desired_times, payload.time.to_s)
      next_state = state.with(desired_times: desired_times)
      [next_state, build_availability_effect_from(next_state)]

    in { type: :toggle_staff, payload: payload }
      desired_staff_ids = toggle_value(state.desired_staff_ids, payload.staff_id.to_i)
      next_state = state.with(desired_staff_ids: desired_staff_ids)
      [next_state, build_availability_effect_from(next_state)]

    in { type: :reset_days }
      next_state = state.with(desired_days: [])
      [next_state, build_availability_effect_from(next_state)]

    in { type: :reset_times }
      next_state = state.with(desired_times: [])
      [next_state, build_availability_effect_from(next_state)]

    in { type: :reset_staff }
      next_state = state.with(desired_staff_ids: [])
      [next_state, build_availability_effect_from(next_state)]

    in { type: :availability_loaded, payload: payload }
      state.with(
        available_days: Array(payload.available_days),
        available_times: Array(payload.available_times),
        available_staff_ids: Array(payload.available_staff_ids),
        selected_days: Array(payload.selected_days),
        selected_times: Array(payload.selected_times),
        selected_staff_ids: Array(payload.selected_staff_ids)
      )

    in { type: :go_next }
      return state unless ready_for_final?(state)

      state.with(
        phase: "single",
        final_day: single_value(state.selected_days),
        final_time: single_value(state.selected_times),
        final_staff_id: single_value(state.selected_staff_ids)
      )

    in { type: :back_to_multi }
      state.with(phase: "multi")

    in { type: :select_final_day, payload: payload }
      state.with(final_day: normalize_day(payload.day))

    in { type: :select_final_time, payload: payload }
      state.with(final_time: payload.time.to_s)

    # in { type: :select_final_staff, payload: payload }
    #   state.with(final_staff_id: payload.staff_id.to_i)

    in { type: :confirm_booking }
      return state unless final_ready?(state)

      [state, build_confirmation_effect(state)]

    in { type: :booking_confirmed, payload: payload }
      state.with(confirmed_at: payload.confirmed_at)
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
  end

  def weekday_label(day_key)
    date = Date.parse(day_key.to_s)
    %w[日 月 火 水 木 金 土][date.wday]
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

  def final_ready?(current_state = state)
    current_state.final_day.present? && current_state.final_time.present? && current_state.final_staff_id.present?
  end

  def final_staff_name
    return nil if state.final_staff_id.nil?

    Staff.find_by(id: state.final_staff_id)&.name
  end

  def final_time_range_label
    return nil unless final_ready?

    start_time = Time.zone.parse("#{state.final_day} #{state.final_time}")
    end_time = start_time + 60.minutes
    "#{start_time.strftime("%Y年%-m月%-d日 %H:%M")}~#{end_time.strftime("%H:%M")}"
  end

  def final_confirmation_message
    return nil unless final_ready?

    time_label = final_time_range_label
    staff_name = final_staff_name
    return nil if time_label.nil? || staff_name.nil?

    "#{time_label}に#{staff_name}がお待ちしております"
  end

  def ready_for_final?(current_state = state)
    current_state.desired_days.any? && current_state.desired_times.any? && current_state.desired_staff_ids.any?
  end

  private

  def single_value(values)
    items = Array(values)
    items.size == 1 ? items.first : nil
  end

  def build_availability_effect_from(current_state)
    build_availability_effect(
      desired_days: current_state.desired_days,
      desired_times: current_state.desired_times,
      desired_staff_ids: current_state.desired_staff_ids
    )
  end

  def build_availability_effect(desired_days:, desired_times:, desired_staff_ids:)
    recalc = recalculate_active(
      desired_days: desired_days,
      desired_times: desired_times,
      desired_staff_ids: desired_staff_ids
    )

    emit(
      :availability_loaded,
      available_days: recalc[:available_days],
      available_times: recalc[:available_times],
      available_staff_ids: recalc[:available_staff_ids],
      selected_days: recalc[:active_days],
      selected_times: recalc[:active_times],
      selected_staff_ids: recalc[:active_staff_ids]
    )
  end

  def build_confirmation_effect(current_state)
    emit(
      :booking_confirmed,
      confirmed_at: Time.current.iso8601,
      final_day: current_state.final_day,
      final_time: current_state.final_time,
      final_staff_id: current_state.final_staff_id
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
      day_values = selected_days.map { |day_key| Date.parse(day_key.to_s) }
      TimeSlot
        .with_staff_ids(selected_staff_ids)
        .on_days(day_values)
        .at_times(selected_times)
        .includes(:staff)
        .to_a
    end
  end
end
