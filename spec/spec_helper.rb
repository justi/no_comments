# frozen_string_literal: true

# spec/spec_helper.rb

require "bundler/setup"
require "cleanio"

RSpec.configure do |config|
  # Ustawienia RSpec
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
  end

  # Inne konfiguracje...
end
