# frozen_string_literal: true

require "open3"

RSpec.describe "Cleanio CLI" do
  let(:temp_file) { "temp_test.rb" }

  before do
    File.write(temp_file, <<~RUBY)
      # This is a comment
      def hello
        puts "Hello, world!" # Inline comment
      end
    RUBY
  end

  after do
    FileUtils.rm_f(temp_file)
  end

  it "runs in audit mode and displays comments" do
    command = "exe/cleanio -f #{temp_file} --audit"
    stdout, stderr, status = Open3.capture3(command)

    expect(status.success?).to be true
    expect(stdout).to include("File: #{temp_file}")
    expect(stdout).to include("Line 1: # This is a comment")
    expect(stdout).to include("Line 3: # Inline comment")
    expect(stderr).to eq("")
  end

  it "cleans comments from the file in standard mode" do
    command = "exe/cleanio -f #{temp_file}"
    stdout, stderr, status = Open3.capture3(command)

    expect(status.success?).to be true
    expect(stdout).to include("File cleaned successfully.")
    expect(stderr).to eq("")

    cleaned_content = File.read(temp_file)
    expected_content = <<~RUBY
      def hello
        puts "Hello, world!"
      end
    RUBY

    expect(cleaned_content).to eq(expected_content)
  end
end
