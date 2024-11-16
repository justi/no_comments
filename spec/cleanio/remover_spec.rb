# frozen_string_literal: true

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

    context "when the file contains '#' in regex or symbols" do
      it "does not remove '#' from regex or symbols" do
        original_code = <<~RUBY
          def test_regex
            regex = /#\\d+/
            symbol = :"test#"
            # This is a comment
          end
        RUBY

        expected_code = <<~RUBY
          def test_regex
            regex = /#\\d+/
            symbol = :"test#"
          end
        RUBY

        File.write(temp_file, original_code)
        described_class.clean(temp_file)
        cleaned_code = File.read(temp_file)

        expect(cleaned_code).to eq(expected_code)
      end
    end

    context "when audit mode is enabled" do
      it "prints the file path and lines with comments" do
        original_code = <<~RUBY
          # This is a comment
          def hello
            puts "Hello, world!" # Inline comment
          end
          # Another comment
        RUBY

        expected_output = <<~OUTPUT
          File: temp_test.rb
            Line 1: # This is a comment
            Line 3: # Inline comment
            Line 5: # Another comment
        OUTPUT

        File.write(temp_file, original_code)

        expect { described_class.clean(temp_file, audit: true) }.to output(expected_output).to_stdout
      end
    end

    context "when a directory path is provided" do
      let(:temp_directory) { "temp_test_dir" }

      before do
        Dir.mkdir(temp_directory)
        File.write("#{temp_directory}/file1.rb", <<~RUBY)
          # Comment in file1
          def method1
            puts "File 1" # Inline comment
          end
        RUBY

        Dir.mkdir("#{temp_directory}/subdir")
        File.write("#{temp_directory}/subdir/file2.rb", <<~RUBY)
          def method2
            # Comment in file2
            puts "File 2"
          end
        RUBY
      end

      after do
        FileUtils.rm_rf(temp_directory)
      end

      context "when it runs in standard mode" do
        it "cleans all .rb files in the directory" do
          described_class.clean(temp_directory)

          cleaned_content_file1 = File.read("#{temp_directory}/file1.rb")
          expected_content_file1 = <<~RUBY
            def method1
              puts "File 1"
            end
          RUBY
          expect(cleaned_content_file1).to eq(expected_content_file1)

          cleaned_content_file2 = File.read("#{temp_directory}/subdir/file2.rb")
          expected_content_file2 = <<~RUBY
            def method2
              puts "File 2"
            end
          RUBY
          expect(cleaned_content_file2).to eq(expected_content_file2)
        end
      end

      context "when it runs in audit mode" do
        it "prints comments from all .rb files in the directory" do
          expected_output = <<~OUTPUT
            File: #{temp_directory}/file1.rb
              Line 1: # Comment in file1
              Line 3: # Inline comment
            File: #{temp_directory}/subdir/file2.rb
              Line 2: # Comment in file2
          OUTPUT

          expect { described_class.clean(temp_directory, audit: true) }.to output(expected_output).to_stdout
        end
      end
    end

    context "when the file or directory does not exist" do
      it "raises an error" do
        expect do
          described_class.clean("non_existent_path.rb")
        end.to raise_error(Errno::ENOENT)
      end
    end

    context "when the file is empty" do
      it "does not raise an error and leaves the file unchanged" do
        File.write(temp_file, "")
        described_class.clean(temp_file)
        cleaned_code = File.read(temp_file)
        expect(cleaned_code).to eq("")
      end
    end
  end
end
