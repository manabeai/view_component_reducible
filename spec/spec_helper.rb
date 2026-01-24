# frozen_string_literal: true

require 'view_component_reducible'

RSpec.configure do |config|
  support_files = Dir[File.join(__dir__, 'support/**/*.rb')].sort
  support_files.each { |file| require file }
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include ViewComponentReducible::RequestSpecHelpers, type: :request if defined?(RSpec::Rails)
end
