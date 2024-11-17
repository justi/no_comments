# frozen_string_literal: true

require "spec_helper"
RSpec.describe NoComments::LineParser do
  include described_class
  describe "#split_line" do
    it "splits a line with a comment outside of quotes" do
      line = "def hello_world # This is a comment"
      code_part, comment_part = split_line(line)
      expect(code_part).to eq("def hello_world ")
      expect(comment_part).to eq("# This is a comment")
    end

    it "does not split a line with # inside a string" do
      line = 'puts "Hello, #world!"'
      code_part, comment_part = split_line(line)
      expect(code_part).to eq(line)
      expect(comment_part).to be_nil
    end

    it "does not split a line with # inside single-quoted string" do
      line = "puts 'Hello, #world!'"
      code_part, comment_part = split_line(line)
      expect(code_part).to eq(line)
      expect(comment_part).to be_nil
    end

    it "does not split a line with # inside regex" do
      line = 'regex = /#\d+/'
      code_part, comment_part = split_line(line)
      expect(code_part).to eq(line)
      expect(comment_part).to be_nil
    end

    it "handles backslash escaping correctly" do
      line = 'puts "\\#" # comment'
      code_part, comment_part = split_line(line)
      expect(code_part).to eq('puts "\\#" ')
      expect(comment_part).to eq("# comment")
    end

    it "handles lines without comments" do
      line = "def hello_world"
      code_part, comment_part = split_line(line)
      expect(code_part).to eq(line)
      expect(comment_part).to be_nil
    end
  end

  describe "#detect_heredoc_start" do
    it "detects heredoc without quoting" do
      line = "message = <<HEREDOC"
      heredoc_start = detect_heredoc_start(line)
      expect(heredoc_start).to eq("HEREDOC")
    end

    it "detects heredoc with double quotes" do
      line = 'message = <<-"HEREDOC"'
      heredoc_start = detect_heredoc_start(line)
      expect(heredoc_start).to eq("HEREDOC")
    end

    it "detects heredoc with single quotes" do
      line = "message = <<-'HEREDOC'"
      heredoc_start = detect_heredoc_start(line)
      expect(heredoc_start).to eq("HEREDOC")
    end

    it "returns nil for lines without heredoc" do
      line = "def example_method"
      heredoc_start = detect_heredoc_start(line)
      expect(heredoc_start).to be_nil
    end
  end

  describe "#update_heredoc_state" do
    it "returns false when heredoc delimiter is matched" do
      in_heredoc, heredoc_delimiter = update_heredoc_state("HEREDOC", "HEREDOC")
      expect(in_heredoc).to be false
      expect(heredoc_delimiter).to be_nil
    end

    it "returns true when heredoc delimiter is not matched" do
      in_heredoc, heredoc_delimiter = update_heredoc_state("Some content", "HEREDOC")
      expect(in_heredoc).to be true
      expect(heredoc_delimiter).to eq("HEREDOC")
    end
  end

  describe "#preceding_char_is_operator?" do
    it "returns true if preceding non-whitespace character is an operator" do
      line = "x =~ /pattern/"
      expect(preceding_char_is_operator?(line, 5)).to be true
    end

    it "returns false if preceding non-whitespace character is not an operator" do
      line = 'puts "/path/to/file"'
      expect(preceding_char_is_operator?(line, 6)).to be false
    end

    describe "#preceding_char_is_operator?" do
      it "returns true when index is at the beginning of the line" do
        line = "/pattern/"
        expect(preceding_char_is_operator?(line, 0)).to be true
      end

      it "returns false when preceding character is alphanumeric" do
        line = "variable/pattern/"
        expect(preceding_char_is_operator?(line, 8)).to be false
      end

      it "returns true when preceding character is an opening parenthesis" do
        line = "puts(/pattern/)"
        expect(preceding_char_is_operator?(line, 5)).to be true
      end

      it "returns true when preceding character is an opening bracket" do
        line = "array[/pattern/]"
        expect(preceding_char_is_operator?(line, 6)).to be true
      end

      it "returns false when preceding character is a closing parenthesis" do
        line = "method_name()/pattern/"
        expect(preceding_char_is_operator?(line, 13)).to be false
      end

      it "returns false when preceding character is a dot" do
        line = "object.method_name/pattern/"
        expect(preceding_char_is_operator?(line, 14)).to be false
      end

      it "returns true when preceding character is a comma" do
        line = "method(arg1, /pattern/)"
        expect(preceding_char_is_operator?(line, 12)).to be true
      end

      it "returns true when preceding character is a colon" do
        line = "{ key: /pattern/ }"
        expect(preceding_char_is_operator?(line, 7)).to be true
      end

      it "returns true when preceding character is a semicolon" do
        line = "stmt1; /pattern/"
        expect(preceding_char_is_operator?(line, 7)).to be true
      end

      it "returns true when preceding character is a question mark" do
        line = "condition ? /yes/ : /no/"
        expect(preceding_char_is_operator?(line, 12)).to be true
      end

      it "returns false when preceding character is a digit" do
        line = "10/2"
        expect(preceding_char_is_operator?(line, 2)).to be false
      end

      it "returns false when preceding character is a closing bracket" do
        line = "array[1]/2"
        expect(preceding_char_is_operator?(line, 8)).to be false
      end

      it "returns true when preceding character is an operator in an expression" do
        line = "result = x + /pattern/"
        expect(preceding_char_is_operator?(line, 13)).to be true
      end

      it "returns false when preceding character is a quote character" do
        line = 'puts "/path/to/file"'
        expect(preceding_char_is_operator?(line, 6)).to be false
      end

      it "returns true when preceding character is an exclamation mark" do
        line = "if !/pattern/.match(string)"
        expect(preceding_char_is_operator?(line, 4)).to be true
      end

      it "returns true when preceding character is a tilde" do
        line = "x = ~/pattern/"
        expect(preceding_char_is_operator?(line, 5)).to be true
      end

      it "returns false when preceding character is an underscore" do
        line = "variable_/pattern/"
        expect(preceding_char_is_operator?(line, 9)).to be false
      end

      it "returns false when preceding character is a dollar sign" do
        line = "$variable/pattern/"
        expect(preceding_char_is_operator?(line, 9)).to be false
      end

      it "returns false when preceding character is an at sign" do
        line = "@variable/pattern/"
        expect(preceding_char_is_operator?(line, 9)).to be false
      end

      it "returns true when preceding character is a double colon" do
        line = "Module::/pattern/"
        expect(preceding_char_is_operator?(line, 8)).to be true
      end

      it "returns false when index is out of bounds" do
        line = "some text"
        expect(preceding_char_is_operator?(line, 20)).to be false
      end

      it "returns false when preceding character is a newline character" do
        line = "some text\n/pattern/"
        expect(preceding_char_is_operator?(line, 10)).to be false
      end

      it "returns true when line is empty and index is zero" do
        line = ""
        expect(preceding_char_is_operator?(line, 0)).to be true
      end

      it "returns false when preceding character is a backslash" do
        line = 'path\\file'
        expect(preceding_char_is_operator?(line, 4)).to be false
      end

      it "returns true when preceding character is an equal sign" do
        line = "regex = /pattern/"
        expect(preceding_char_is_operator?(line, 8)).to be true
      end

      it "returns false when preceding character is a letter after whitespace" do
        line = "method_name /pattern/"
        expect(preceding_char_is_operator?(line, 12)).to be false
      end

      it "returns false when preceding character is a number after whitespace" do
        line = "number /2"
        expect(preceding_char_is_operator?(line, 7)).to be false
      end
    end
  end
end
