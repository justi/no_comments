# frozen_string_literal: true

require "spec_helper"

RSpec.describe NoComments::ContentProcessor do
  let(:processor) { described_class.new }

  describe "#process" do
    context "when the content is empty" do
      it "returns empty cleaned content and no comments" do
        content = ""
        cleaned_content, comments = processor.process(content)

        expect(cleaned_content).to eq("")
        expect(comments).to be_empty
      end
    end

    context "when the content has no comments" do
      it "returns the content unchanged and no comments" do
        content = <<~RUBY
          def hello
            puts 'Hello, world!'
          end
        RUBY

        cleaned_content, comments = processor.process(content)

        expect(cleaned_content).to eq(content)
        expect(comments).to be_empty
      end
    end

    context "when the content has single-line comments" do
      it "removes single-line comments and collects them" do
        content = <<~RUBY
          # This is a comment
          def hello
            puts 'Hello, world!'
          end
        RUBY

        expected_cleaned_content = <<~RUBY
          def hello
            puts 'Hello, world!'
          end
        RUBY

        cleaned_content, comments = processor.process(content)

        expect(cleaned_content).to eq(expected_cleaned_content)
        expect(comments).to eq([
                                 [1, "# This is a comment"]
                               ])
      end
    end

    context "when the content has inline comments" do
      it "removes inline comments and collects them" do
        content = <<~RUBY
          def hello # This is a method
            puts 'Hello, world!' # Greet the world
          end
        RUBY

        expected_cleaned_content = <<~RUBY
          def hello
            puts 'Hello, world!'
          end
        RUBY

        cleaned_content, comments = processor.process(content)

        expect(cleaned_content).to eq(expected_cleaned_content)
        expect(comments).to eq([
                                 [1, "# This is a method"],
                                 [2, "# Greet the world"]
                               ])
      end
    end

    context "when the content has multi-line comments" do
      it "removes multi-line comments and collects them" do
        content = <<~RUBY
          def example_method
            =begin
            This is a multi-line comment.
            It should be removed.
            =end
            puts 'After comment'
          end
        RUBY

        expected_cleaned_content = <<~RUBY
          def example_method
            puts 'After comment'
          end
        RUBY

        cleaned_content, comments = processor.process(content)

        expect(cleaned_content).to eq(expected_cleaned_content)
        expect(comments).to eq([
                                 [2, "=begin"],
                                 [3, "This is a multi-line comment."],
                                 [4, "It should be removed."],
                                 [5, "=end"]
                               ])
      end
    end

    context "when the content has strings with # characters" do
      it "does not remove # characters inside strings" do
        content = <<~RUBY
          def greeting
            puts "Hello, #world!" # This is a comment
          end
        RUBY

        expected_cleaned_content = <<~RUBY
          def greeting
            puts "Hello, #world!"
          end
        RUBY

        cleaned_content, comments = processor.process(content)

        expect(cleaned_content).to eq(expected_cleaned_content)
        expect(comments).to eq([
                                 [2, "# This is a comment"]
                               ])
      end
    end

    context "when the content has heredocs" do
      it "handles heredocs correctly" do
        content = <<~RUBY
          def multi_line
            puts <<~HEREDOC
              Hello, #world!
              This is a multi-line string.
            HEREDOC
            # This is a comment
          end
        RUBY

        expected_cleaned_content = <<~RUBY
          def multi_line
            puts <<~HEREDOC
              Hello, #world!
              This is a multi-line string.
            HEREDOC
          end
        RUBY

        cleaned_content, comments = processor.process(content)

        expect(cleaned_content).to eq(expected_cleaned_content)
        expect(comments).to eq([
                                 [6, "# This is a comment"]
                               ])
      end
    end

    context "when the content has regexes with # characters" do
      it "does not remove # characters inside regexes" do
        content = <<~RUBY
          def test_regex
            regex = /#\\d+/
            symbol = :"test#"
            # This is a comment
          end
        RUBY

        expected_cleaned_content = <<~RUBY
          def test_regex
            regex = /#\\d+/
            symbol = :"test#"
          end
        RUBY

        cleaned_content, comments = processor.process(content)

        expect(cleaned_content).to eq(expected_cleaned_content)
        expect(comments).to eq([
                                 [4, "# This is a comment"]
                               ])
      end
    end

    context "when the content is complex" do
      it "handles various cases correctly" do
        content = <<~RUBY
          # Initial comment
          def complex_method
            puts "String with # not a comment"
            regex = /#\\d+/
            =begin
            Multi-line comment
            =end
            puts <<~HEREDOC
              Heredoc with # not a comment
            HEREDOC
            # Final comment
          end
        RUBY

        expected_cleaned_content = <<~RUBY
          def complex_method
            puts "String with # not a comment"
            regex = /#\\d+/
            puts <<~HEREDOC
              Heredoc with # not a comment
            HEREDOC
          end
        RUBY

        cleaned_content, comments = processor.process(content)

        expect(cleaned_content).to eq(expected_cleaned_content)
        expect(comments).to eq([
                                 [1, "# Initial comment"],
                                 [5, "=begin"],
                                 [6, "Multi-line comment"],
                                 [7, "=end"],
                                 [11, "# Final comment"]
                               ])
      end
    end

    # Add these test cases within the existing describe '#process' do block

    context "when the content has Emacs-style magic comments" do
      it "preserves Emacs-style magic comments" do
        content = <<~RUBY
          # -*- coding: big5; mode: ruby; frozen_string_literal: true -*-
          # This is a regular comment
          def example_method
            puts 'Hello, world!' # Inline comment
          end
        RUBY

        expected_cleaned_content = <<~RUBY
          # -*- coding: big5; mode: ruby; frozen_string_literal: true -*-
          def example_method
            puts 'Hello, world!'
          end
        RUBY

        cleaned_content, comments = processor.process(content)

        expect(cleaned_content).to eq(expected_cleaned_content)
        expect(comments).to eq([
                                 [2, "# This is a regular comment"],
                                 [4, "# Inline comment"]
                               ])
      end
    end

    context "when the content has Vim-style magic comments" do
      it "preserves Vim-style magic comments" do
        content = <<~RUBY
          # vim: set fileencoding=utf-8 :
          # encoding: utf-8
          # frozen_string_literal: true
          # This is a regular comment
          def example_method
            puts 'Hello, world!' # Inline comment
          end
        RUBY

        expected_cleaned_content = <<~RUBY
          # vim: set fileencoding=utf-8 :
          # encoding: utf-8
          # frozen_string_literal: true
          def example_method
            puts 'Hello, world!'
          end
        RUBY

        cleaned_content, comments = processor.process(content)

        expect(cleaned_content).to eq(expected_cleaned_content)
        expect(comments).to eq([
                                 [4, "# This is a regular comment"],
                                 [6, "# Inline comment"]
                               ])
      end
    end
    # In spec/no_comments/content_processor_spec.rb

    context "when magic comments appear after the allowed lines" do
      it "does not preserve magic comments not at the top of the file" do
        content = <<~RUBY
          # frozen_string_literal: true
          def example_method
            # encoding: utf-8
            puts 'Hello, world!' # Inline comment
            # -*- coding: big5; mode: ruby; frozen_string_literal: true -*-
          end
        RUBY

        expected_cleaned_content = <<~RUBY
          # frozen_string_literal: true
          def example_method
            puts 'Hello, world!'
          end
        RUBY

        cleaned_content, comments = processor.process(content)

        expect(cleaned_content).to eq(expected_cleaned_content)
        expect(comments).to eq([
                                 [3, "# encoding: utf-8"],
                                 [4, "# Inline comment"],
                                 [5, "# -*- coding: big5; mode: ruby; frozen_string_literal: true -*-"]
                               ])
      end
    end

    context "when the file has a shebang line" do
      it "allows magic comments on the second line" do
        content = <<~RUBY
          #!/usr/bin/env ruby
          # frozen_string_literal: true
          def example_method
            puts 'Hello, world!' # Inline comment
          end
        RUBY

        expected_cleaned_content = <<~RUBY
          #!/usr/bin/env ruby
          # frozen_string_literal: true
          def example_method
            puts 'Hello, world!'
          end
        RUBY

        cleaned_content, comments = processor.process(content)

        expect(cleaned_content).to eq(expected_cleaned_content)
        expect(comments).to eq([
                                 [4, "# Inline comment"]
                               ])
      end

      it "does not preserve magic comments beyond the second line" do
        content = <<~RUBY
          #!/usr/bin/env ruby
          def example_method
            # frozen_string_literal: true
            puts 'Hello, world!' # Inline comment
          end
        RUBY

        expected_cleaned_content = <<~RUBY
          #!/usr/bin/env ruby
          def example_method
            puts 'Hello, world!'
          end
        RUBY

        cleaned_content, comments = processor.process(content)

        expect(cleaned_content).to eq(expected_cleaned_content)
        expect(comments).to eq([
                                 [3, "# frozen_string_literal: true"],
                                 [4, "# Inline comment"]
                               ])
      end
    end
  end
end
