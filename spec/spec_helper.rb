# frozen_string_literal: true

require "bundler/setup"
require "no_comments"
require "no_comments/content_processor"
require "no_comments/comment_detector"
require "no_comments/line_parser"
require "fileutils"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end
  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
  end
end
