# frozen_string_literal: true

# spec/cleanio/remover_spec.rb

require "spec_helper"

RSpec.describe Cleanio::Remover do
  describe ".clean" do
    let(:temp_file) { "temp_test.rb" }

    after do
      FileUtils.rm_f(temp_file)
    end

    context "when the file has only code without comments" do
      it "leaves the code unchanged" do
        original_code = <<~RUBY
          def hello
            puts "Hello, world!"
          end
        RUBY

        File.write(temp_file, original_code)
        described_class.clean(temp_file)
        cleaned_code = File.read(temp_file)

        expect(cleaned_code).to eq(original_code)
      end
    end

    context "when the file has single-line comments" do
      it "removes the comment lines" do
        original_code = <<~RUBY
          # This is a comment
          def hello
            puts "Hello, world!"
          # Another comment
          end
        RUBY

        expected_code = <<~RUBY
          def hello
            puts "Hello, world!"
          end
        RUBY

        File.write(temp_file, original_code)
        described_class.clean(temp_file)
        cleaned_code = File.read(temp_file)

        expect(cleaned_code).to eq(expected_code)
      end
    end

    context "when the file has inline comments" do
      it "removes the inline comments" do
        original_code = <<~RUBY
          def hello
            puts "Hello, world!" # Print greeting
          end
        RUBY

        expected_code = <<~RUBY
          def hello
            puts "Hello, world!"
          end
        RUBY

        File.write(temp_file, original_code)
        described_class.clean(temp_file)
        cleaned_code = File.read(temp_file)

        expect(cleaned_code).to eq(expected_code)
      end
    end

    context "when the file has mixed comments and code" do
      it "removes all comments correctly" do
        original_code = <<~RUBY
          # Initial comment
          def hello # Define method
            # Inside method
            puts "Hello, world!" # Print message
          end # End of method
        RUBY

        expected_code = <<~RUBY
          def hello
            puts "Hello, world!"
          end
        RUBY

        File.write(temp_file, original_code)
        described_class.clean(temp_file)
        cleaned_code = File.read(temp_file)

        expect(cleaned_code).to eq(expected_code)
      end
    end

    context "when the file does not end with .rb" do
      it "raises an error" do
        expect do
          described_class.clean("plik.txt")
        end.to raise_error("Only Ruby files are supported")
      end
    end

    context "when the file contains strings with # characters" do
      it "does not remove content inside strings" do
        original_code = <<~RUBY
          def greeting
            puts "Hello, #world!" # This is a comment
          end
        RUBY

        expected_code = <<~RUBY
          def greeting
            puts "Hello, #world!"
          end
        RUBY

        File.write(temp_file, original_code)
        described_class.clean(temp_file)
        cleaned_code = File.read(temp_file)

        expect(cleaned_code).to eq(expected_code)
      end
    end

    context "when the file contains multi-line strings with # characters" do
      it "does not remove content inside multi-line strings" do
        original_code = <<~RUBY
          def multi_line
            puts <<~HEREDOC
              Hello, #world!
              This is a multi-line string.
            HEREDOC
            # This is a comment
          end
        RUBY

        expected_code = <<~RUBY
          def multi_line
            puts <<~HEREDOC
              Hello, #world!
              This is a multi-line string.
            HEREDOC
          end
        RUBY

        File.write(temp_file, original_code)
        described_class.clean(temp_file)
        cleaned_code = File.read(temp_file)

        expect(cleaned_code).to eq(expected_code)
      end
    end
  end
end
