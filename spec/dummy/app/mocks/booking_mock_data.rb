# frozen_string_literal: true

module BookingMockData
  Day = Struct.new(:day, :date, :weekday, :status, keyword_init: true)
  DAYS = (1..30).to_a.freeze
  TIME_OPTIONS = (9..18).map { |hour| format("%02d:00", hour) }.freeze
  BASE_TIMES = ["10:00", "14:00"].freeze
  BASE_STAFF = ["Aki"].freeze
  STATUS_MARKS = %w[circle triangle cross].freeze
  WEEKDAYS = %w[日 月 火 水 木 金 土].freeze

  module_function

  def calendar_days
    DAYS.map do |day|
      {
        'day' => day,
        'date' => format("3/%02d", day),
        'weekday' => WEEKDAYS[(day - 1) % WEEKDAYS.length],
        'status' => STATUS_MARKS[day % STATUS_MARKS.length]
      }
    end
  end

  def calendar_day_records(days)
    Array(days).map do |day|
      payload = day.is_a?(Hash) ? day.transform_keys(&:to_sym) : {}
      Day.new(
        day: payload.fetch(:day, nil),
        date: payload.fetch(:date, nil),
        weekday: payload.fetch(:weekday, nil),
        status: payload.fetch(:status, nil)
      )
    end
  end

  def base_times
    BASE_TIMES
  end

  def base_staff
    BASE_STAFF
  end

  def available_times
    count = rand(1..6)
    TIME_OPTIONS.sample(count)
  end

  def available_staff(options:)
    return [] if options.empty?

    min_count = [2, options.size].min
    count = rand(min_count..options.size)
    options.sample(count)
  end
end
