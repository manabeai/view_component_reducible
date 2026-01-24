# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
ENV['VCR_ADAPTER'] ||= 'hidden_field'

require_relative 'spec_helper'
require File.expand_path('dummy/config/environment', __dir__)
require 'rspec/rails'

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.include ViewComponentReducible::RequestSpecHelpers, type: :request
end
