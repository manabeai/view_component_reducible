# frozen_string_literal: true

class TimeSlot < ApplicationRecord
  belongs_to :staff

  validates :time_range, presence: true

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
