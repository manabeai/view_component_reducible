# frozen_string_literal: true

class TimeSlot < ApplicationRecord
  belongs_to :staff

  validates :time_range, presence: true

  scope :with_staff_ids, ->(ids) { ids.blank? ? all : where(staff_id: ids) }
  scope :on_days, lambda { |days|
    return all if days.blank?

    where(Arel.sql("DATE(LOWER(time_range)) IN (?)"), days)
  }
  scope :at_times, lambda { |times|
    return all if times.blank?

    where(Arel.sql("TO_CHAR(LOWER(time_range), 'HH24:MI') IN (?)"), times)
  }

  def start_time
    time_range&.begin
  end

  def day_key
    start_time&.to_date&.iso8601
  end

  def time_label
    start_time&.strftime("%H:%M")
  end
end
