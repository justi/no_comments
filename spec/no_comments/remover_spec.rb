# frozen_string_literal: true

require "spec_helper"
require "parser/current"
RSpec.describe NoComments::Remover do
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

    context "when the file contains a class with multiple methods, constants, includes, and comments" do
      it "removes all comments correctly" do
        original_code = <<~RUBY
          # Class comment
          class MyClass
            include Enumerable # Include module

            # Constant declaration
            MY_CONSTANT = 42 # The answer to everything

            # One-line method
            def self.greet; puts 'Hello!' end # Greet method

            # Regular method
            def calculate(value)
              # Perform calculation
              value * MY_CONSTANT # Multiply by constant
            end

            # Another method
            def each(&block)
              # Iteration logic
              [1, 2, 3].each(&block) # Iterate over array
            end
          end # End of MyClass
        RUBY

        expected_code = <<~RUBY
          class MyClass
            include Enumerable

            MY_CONSTANT = 42

            def self.greet; puts 'Hello!' end

            def calculate(value)
              value * MY_CONSTANT
            end

            def each(&block)
              [1, 2, 3].each(&block)
            end
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

    context "when the file contains documentation comments" do
      it "removes documentation comments by default" do
        original_code = <<~RUBY
          # @param name [String]
          def greet(name)
            puts name
          end
        RUBY
        expected_code = <<~RUBY
          def greet(name)
            puts name
          end
        RUBY
        File.write(temp_file, original_code)
        described_class.clean(temp_file)
        cleaned_code = File.read(temp_file)
        expect(cleaned_code).to eq(expected_code)
      end

      it "preserves documentation comments when keep_doc_comments is true" do
        original_code = <<~RUBY
          # @param name [String]
          def greet(name)
            puts name
          end
        RUBY
        File.write(temp_file, original_code)
        described_class.clean(temp_file, keep_doc_comments: true)
        cleaned_code = File.read(temp_file)
        expect(cleaned_code).to eq(original_code)
      end
    end

    context "when the file contains inline documentation comments" do
      it "removes them by default" do
        original_code = <<~RUBY
          def greet(name) # @param name [String]
            puts name # @return [void]
          end
        RUBY
        expected_code = <<~RUBY
          def greet(name)
            puts name
          end
        RUBY
        File.write(temp_file, original_code)
        described_class.clean(temp_file)
        cleaned_code = File.read(temp_file)
        expect(cleaned_code).to eq(expected_code)
      end

      it "preserves inline documentation comments when keep_doc_comments is true" do
        original_code = <<~RUBY
          def greet(name) # @param name [String]
            puts name # @return [void]
          end
        RUBY
        File.write(temp_file, original_code)
        described_class.clean(temp_file, keep_doc_comments: true)
        cleaned_code = File.read(temp_file)
        expect(cleaned_code).to eq(original_code)
      end
    end

    context "when the file contains class documentation comments" do
      it "removes them by default" do
        original_code = <<~RUBY
          # Documentation
          class Test
          end
        RUBY
        expected_code = <<~RUBY
          class Test
          end
        RUBY
        File.write(temp_file, original_code)
        described_class.clean(temp_file)
        cleaned_code = File.read(temp_file)
        expect(cleaned_code).to eq(expected_code)
      end

      it "preserves them when keep_doc_comments is true" do
        original_code = <<~RUBY
          # Documentation
          class Test
          end
        RUBY
        File.write(temp_file, original_code)
        described_class.clean(temp_file, keep_doc_comments: true)
        cleaned_code = File.read(temp_file)
        expect(cleaned_code).to eq(original_code)
      end
    end

    context "when the file contains nodoc comments" do
      it "removes them by default" do
        original_code = <<~RUBY
          class Test # :nodoc:
          end
        RUBY
        expected_code = <<~RUBY
          class Test
          end
        RUBY
        File.write(temp_file, original_code)
        described_class.clean(temp_file)
        cleaned_code = File.read(temp_file)
        expect(cleaned_code).to eq(expected_code)
      end

      it "preserves them when keep_doc_comments is true" do
        original_code = <<~RUBY
          class Test # :nodoc:
          end
        RUBY
        File.write(temp_file, original_code)
        described_class.clean(temp_file, keep_doc_comments: true)
        cleaned_code = File.read(temp_file)
        expect(cleaned_code).to eq(original_code)
      end
    end

    context "when the file contains multi-line comments" do
      it "removes the multi-line comments" do
        original_code = <<~RUBY
          def example_method
            =begin
            This is a multi-line comment.
            It should be removed.
            =end
            puts "Code after multi-line comment"
          end
        RUBY
        expected_code = <<~RUBY
          def example_method
            puts "Code after multi-line comment"
          end
        RUBY
        File.write(temp_file, original_code)
        described_class.clean(temp_file)
        cleaned_code = File.read(temp_file)
        expect(cleaned_code).to eq(expected_code)
      end
    end

    context "when the file contains multi-line comments in audit mode" do
      it "prints the multi-line comments with correct line numbers" do
        original_code = <<~RUBY
          def example_method
            =begin
            This is a multi-line comment.
            It should be displayed in audit.
            =end
            puts "Code after multi-line comment"
          end
        RUBY
        expected_output = <<~OUTPUT
          File: #{temp_file}
            Line 2: =begin
            Line 3: This is a multi-line comment.
            Line 4: It should be displayed in audit.
            Line 5: =end
        OUTPUT
        File.write(temp_file, original_code)
        expect { described_class.clean(temp_file, audit: true) }.to output(expected_output).to_stdout
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

      context "when keep_doc_comments is true" do
        before do
          File.write("#{temp_directory}/file1.rb", <<~RUBY)
            # @return [String]
            def method1
              puts "File 1"
            end
          RUBY
          File.write("#{temp_directory}/subdir/file2.rb", <<~RUBY)
            def method2 # @param val [Integer]
              puts "File 2"
            end
          RUBY
        end

        it "preserves documentation comments when cleaning" do
          described_class.clean(temp_directory, keep_doc_comments: true)
          expect(File.read("#{temp_directory}/file1.rb")).to eq(<<~RUBY)
            # @return [String]
            def method1
              puts "File 1"
            end
          RUBY
          expect(File.read("#{temp_directory}/subdir/file2.rb")).to eq(<<~RUBY)
            def method2 # @param val [Integer]
              puts "File 2"
            end
          RUBY
        end

        it "produces no output in audit mode" do
          expect { described_class.clean(temp_directory, audit: true, keep_doc_comments: true) }.not_to output.to_stdout
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
