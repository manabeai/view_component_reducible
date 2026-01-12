# frozen_string_literal: true

module BookingMockData
  TIME_OPTIONS = (9..18).map { |hour| format("%02d:00", hour) }.freeze
  BASE_TIMES = ["10:00", "14:00"].freeze
  BASE_STAFF = ["Aki"].freeze

  module_function

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
