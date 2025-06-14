# frozen_string_literal: true

require "open3"
RSpec.describe "no_comments CLI" do
  describe "when file is passed as an argument" do
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
      command = "exe/no_comments -p #{temp_file} --audit"
      stdout, stderr, status = Open3.capture3(command)
      expect(status.success?).to be true
      expect(stdout).to include("File: #{temp_file}")
      expect(stdout).to include("Line 1: # This is a comment")
      expect(stdout).to include("Line 3: # Inline comment")
      expect(stderr).to eq("")
    end

    it "cleans comments from the file in standard mode" do
      command = "exe/no_comments -p #{temp_file}"
      stdout, stderr, status = Open3.capture3(command)
      expect(status.success?).to be true
      expect(stdout).to include("Cleaning completed successfully.\n")
      expect(stderr).to eq("")
      cleaned_content = File.read(temp_file)
      expected_content = <<~RUBY
        def hello
          puts "Hello, world!"
        end
      RUBY
      expect(cleaned_content).to eq(expected_content)
    end

    it "preserves documentation comments when flag passed" do
      File.write(temp_file, <<~RUBY)
        # @return [String]
        def hello
          puts "Hello, world!"
        end
      RUBY
      command = "exe/no_comments -p #{temp_file} --keep-doc-comments"
      stdout, stderr, status = Open3.capture3(command)
      expect(status.success?).to be true
      expect(stdout).to include("Cleaning completed successfully.\n")
      expect(stderr).to eq("")
      cleaned_content = File.read(temp_file)
      expected_content = <<~RUBY
        # @return [String]
        def hello
          puts "Hello, world!"
        end
      RUBY
      expect(cleaned_content).to eq(expected_content)
    end

    it "removes documentation comments by default" do
      File.write(temp_file, <<~RUBY)
        # @return [String]
        def hello
          puts "Hello, world!"
        end
      RUBY
      command = "exe/no_comments -p #{temp_file}"
      stdout, stderr, status = Open3.capture3(command)
      expect(status.success?).to be true
      expect(stdout).to include("Cleaning completed successfully.\n")
      expect(stderr).to eq("")
      cleaned_content = File.read(temp_file)
      expected_content = <<~RUBY
        def hello
          puts "Hello, world!"
        end
      RUBY
      expect(cleaned_content).to eq(expected_content)
    end

    it "audits and preserves documentation comments when flag passed" do
      File.write(temp_file, <<~RUBY)
        # @return [String]
        def hello
          puts "Hello, world!"
        end
      RUBY
      command = "exe/no_comments -p #{temp_file} --audit --keep-doc-comments"
      stdout, stderr, status = Open3.capture3(command)
      expect(status.success?).to be true
      expect(stdout).to include("Audit completed successfully.\n")
      expect(stderr).to eq("")
    end

    it "preserves class documentation with flag" do
      File.write(temp_file, <<~RUBY)
        # Description
        class Foo
        end
      RUBY
      command = "exe/no_comments -p #{temp_file} --keep-doc-comments"
      stdout, stderr, status = Open3.capture3(command)
      expect(status.success?).to be true
      expect(stdout).to include("Cleaning completed successfully.\n")
      expect(stderr).to eq("")
      cleaned_content = File.read(temp_file)
      expected_content = <<~RUBY
        # Description
        class Foo
        end
      RUBY
      expect(cleaned_content).to eq(expected_content)
    end

    it "handles nodoc comments" do
      File.write(temp_file, <<~RUBY)
        class Foo # :nodoc:
        end
      RUBY
      command = "exe/no_comments -p #{temp_file} --keep-doc-comments"
      stdout, stderr, status = Open3.capture3(command)
      expect(status.success?).to be true
      expect(stdout).to include("Cleaning completed successfully.\n")
      expect(stderr).to eq("")
      cleaned_content = File.read(temp_file)
      expected_content = <<~RUBY
        class Foo # :nodoc:
        end
      RUBY
      expect(cleaned_content).to eq(expected_content)
    end
  end

  describe "when directory is passed as an argument" do
    let(:temp_directory) { "temp_test_dir" }

    before do
      Dir.mkdir(temp_directory)
      File.write("#{temp_directory}/file1.rb", <<~RUBY)
        # This is a comment
        def hello
          puts "Hello, world!" # Inline comment
        end
      RUBY
      Dir.mkdir("#{temp_directory}/subdir")
      File.write("#{temp_directory}/subdir/file2.rb", <<~RUBY)
        def greet
          # Another comment
          puts "Hi!"
        end
      RUBY
    end

    after do
      FileUtils.rm_rf(temp_directory)
    end

    it "audits all .rb files in the directory" do
      command = "exe/no_comments -p #{temp_directory} --audit"
      stdout, stderr, status = Open3.capture3(command)
      expect(status.success?).to be true
      expect(stdout).to include("File: #{temp_directory}/file1.rb")
      expect(stdout).to include("Line 1: # This is a comment")
      expect(stdout).to include("File: #{temp_directory}/subdir/file2.rb")
      expect(stdout).to include("Line 2: # Another comment")
      expect(stderr).to eq("")
    end

    it "cleans all .rb files in the directory in standard mode" do
      command = "exe/no_comments -p #{temp_directory}"
      stdout, stderr, status = Open3.capture3(command)
      expect(status.success?).to be true
      expect(stdout).to include("Cleaning completed successfully.\n")
      expect(stderr).to eq("")
      cleaned_content_file1 = File.read("#{temp_directory}/file1.rb")
      expected_content_file1 = <<~RUBY
        def hello
          puts "Hello, world!"
        end
      RUBY
      expect(cleaned_content_file1).to eq(expected_content_file1)
      cleaned_content_file2 = File.read("#{temp_directory}/subdir/file2.rb")
      expected_content_file2 = <<~RUBY
        def greet
          puts "Hi!"
        end
      RUBY
      expect(cleaned_content_file2).to eq(expected_content_file2)
    end

    it "cleans all .rb files in the directory and preserves documentation comments when flag passed" do
      File.write("#{temp_directory}/file1.rb", <<~RUBY)
        # @return [String]
        def hello
          puts "Hello, world!"
        end
      RUBY
      File.write("#{temp_directory}/subdir/file2.rb", <<~RUBY)
        def greet(name) # @param name [String]
          puts "Hi!"
        end
      RUBY
      command = "exe/no_comments -p #{temp_directory} --keep-doc-comments"
      stdout, stderr, status = Open3.capture3(command)
      expect(status.success?).to be true
      expect(stdout).to include("Cleaning completed successfully.\n")
      expect(stderr).to eq("")
      expect(File.read("#{temp_directory}/file1.rb")).to eq(<<~RUBY)
        # @return [String]
        def hello
          puts "Hello, world!"
        end
      RUBY
      expect(File.read("#{temp_directory}/subdir/file2.rb")).to eq(<<~RUBY)
        def greet(name) # @param name [String]
          puts "Hi!"
        end
      RUBY
    end

    it "audits the directory with keep-doc-comments" do
      File.write("#{temp_directory}/file1.rb", <<~RUBY)
        # @return [String]
        def hello
          puts "Hello, world!"
        end
      RUBY
      File.write("#{temp_directory}/subdir/file2.rb", <<~RUBY)
        def greet(name) # @param name [String]
          puts "Hi!"
        end
      RUBY
      command = "exe/no_comments -p #{temp_directory} --audit --keep-doc-comments"
      stdout, stderr, status = Open3.capture3(command)
      expect(status.success?).to be true
      expect(stdout).to include("Audit completed successfully.\n")
      expect(stderr).to eq("")
    end
  end
end
