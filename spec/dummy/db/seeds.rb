# This file should ensure the existence of records required to run the application in every environment.
# The data should be idempotent.

def find_or_create_staff(name)
  Staff.find_or_create_by!(name: name)
end

def ensure_time_slot(staff:, day:, time_label:, duration_minutes: 60)
  start_time = Time.zone.parse("#{day} #{time_label}")
  end_time = start_time + duration_minutes.minutes
  TimeSlot.find_or_create_by!(staff: staff, time_range: (start_time..end_time))
end

Time.zone ||= "Asia/Tokyo"

staff_aki = find_or_create_staff("Aki")
staff_mika = find_or_create_staff("Mika")
staff_sora = find_or_create_staff("Sora")

base_day = Date.current
days = (0..6).map { |offset| base_day + offset }

availability = {
  staff_aki => {
    days[0] => %w[10:00 13:00 16:00],
    days[1] => %w[09:00 12:00 15:00],
    days[2] => %w[11:00 14:00],
    days[3] => %w[10:00 17:00],
    days[4] => %w[09:00 18:00]
  },
  staff_mika => {
    days[0] => %w[11:00 14:00 17:00],
    days[2] => %w[10:00 12:00 15:00],
    days[3] => %w[09:00 13:00 16:00],
    days[5] => %w[10:00 14:00 18:00]
  },
  staff_sora => {
    days[1] => %w[10:00 13:00 19:00],
    days[2] => %w[09:00 11:00 17:00],
    days[4] => %w[10:00 12:00 15:00],
    days[6] => %w[09:00 13:00 16:00]
  }
}

availability.each do |staff, slots_by_day|
  slots_by_day.each do |day, times|
    times.each do |time_label|
      ensure_time_slot(staff: staff, day: day, time_label: time_label)
    end
  end
end
