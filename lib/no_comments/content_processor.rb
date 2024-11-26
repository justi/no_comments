# frozen_string_literal: true

require "no_comments/version"
require "no_comments/comment_detector"
require "no_comments/line_parser"
module NoComments
  class ContentProcessor
    include CommentDetector
    include LineParser
    def initialize
      @comments = []
      @result_lines = []
      @in_multiline_comment = false
      @in_heredoc = false
      @heredoc_delimiter = nil
      @line_number = 0
      @code_started = false
    end

    def process(content)
      lines = content.lines
      lines.each do |line|
        @line_number += 1
        stripped_line = line.strip
        process_line(line, stripped_line)
      end
      cleaned_content = @result_lines.join("\n")
      cleaned_content += "\n" unless cleaned_content.empty?
      [cleaned_content, @comments]
    end

    def process_line(line, stripped_line)
      if @in_multiline_comment
        handle_multiline_comment(stripped_line)
      elsif @in_heredoc
        handle_heredoc(line, stripped_line)
      elsif !@code_started
        handle_initial_lines(line, stripped_line)
      else
        handle_regular_line(line, stripped_line)
      end
    end

    def handle_initial_lines(line, stripped_line)
      if stripped_line.empty? || stripped_line.start_with?("#!") || magic_comment?(stripped_line)
        @result_lines << line.rstrip
      elsif stripped_line.start_with?("#")
        if tool_comment?(stripped_line)
          @result_lines << line.rstrip
        else
          @comments << [@line_number, stripped_line]
        end
      else
        @code_started = true
        handle_regular_line(line, stripped_line)
      end
    end

    def handle_multiline_comment(stripped_line)
      @comments << [@line_number, stripped_line]
      @in_multiline_comment = false if stripped_line == "=end"
    end

    def handle_heredoc(line, stripped_line)
      @result_lines << line.rstrip
      @in_heredoc, @heredoc_delimiter = update_heredoc_state(
        stripped_line, @heredoc_delimiter
      )
    end

    def handle_regular_line(line, stripped_line)
      if stripped_line == "=begin"
        start_multiline_comment(stripped_line)
      elsif (heredoc_start = detect_heredoc_start(line))
        start_heredoc(line, heredoc_start)
      elsif stripped_line.start_with?("#") && tool_comment?(stripped_line)
        @result_lines << line.rstrip
      else
        process_code_line(line)
      end
    end

    def start_multiline_comment(stripped_line)
      @in_multiline_comment = true
      @comments << [@line_number, stripped_line]
    end

    def start_heredoc(line, heredoc_start)
      @in_heredoc = true
      @heredoc_delimiter = heredoc_start
      @result_lines << line.rstrip
    end

    def process_code_line(line)
      code_part, comment_part = split_line(line)
      return handle_empty_line(line) if code_part.strip.empty? && comment_part.nil?
      return handle_tool_comment_line(code_part, comment_part) if comment_part && tool_comment?(comment_part.strip)

      handle_regular_code_line(code_part, comment_part)
    end

    private

    def handle_empty_line(line)
      @result_lines << line.rstrip
    end

    def handle_tool_comment_line(code_part, comment_part)
      @result_lines << ("#{code_part.rstrip} #{comment_part.strip}")
    end

    def handle_regular_code_line(code_part, comment_part)
      @comments << [@line_number, comment_part.strip] if comment_part
      return if code_part.strip.empty?

      @result_lines << code_part.rstrip
    end
  end
end
