# frozen_string_literal: true

module BookingMockData
  Day = Struct.new(:day, :date, :weekday, :status, :year, :month, keyword_init: true)
  DAYS = (1..30).to_a.freeze
  YEAR = 2024
  MONTH = 3
  TIME_OPTIONS = (9..18).map { |hour| format("%02d:00", hour) }.freeze
  BASE_TIMES = ["10:00", "14:00"].freeze
  BASE_STAFF = ["Aki"].freeze
  STAFF_OPTIONS = ["Aki", "Mika", "Sora"].freeze
  STATUS_MARKS = %w[circle triangle cross].freeze
  WEEKDAYS = %w[日 月 火 水 木 金 土].freeze

  module_function

  def calendar_days
    DAYS.map do |day|
      {
        'day' => day,
        'date' => format("%d/%02d", MONTH, day),
        'weekday' => WEEKDAYS[(day - 1) % WEEKDAYS.length],
        'status' => STATUS_MARKS[day % STATUS_MARKS.length],
        'year' => YEAR,
        'month' => MONTH
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
        status: payload.fetch(:status, nil),
        year: payload.fetch(:year, nil),
        month: payload.fetch(:month, nil)
      )
    end
  end

  def base_times
    BASE_TIMES
  end

  def base_staff
    BASE_STAFF
  end

  def available_times(day:)
    count = (day.to_i % 6) + 1
    start = day.to_i % TIME_OPTIONS.length
    TIME_OPTIONS.rotate(start).first(count)
  end

  def available_staff(options:, time:)
    return [] if options.empty?

    min_count = [2, options.size].min
    seed = time.to_s.bytes.sum
    range = options.size - min_count
    count = min_count + (range.zero? ? 0 : seed % (range + 1))
    options.rotate(seed % options.size).first(count)
  end
end
