# frozen_string_literal: true

require "no_comments/version"

module NoComments
  class ContentProcessor
    def initialize
      @comments = []
      @result_lines = []
      @in_multiline_comment = false
      @in_heredoc = false
      @heredoc_delimiter = nil
      @line_number = 0
    end

    def process(content)
      content.each_line do |line|
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
      else
        handle_regular_line(line, stripped_line)
      end
    end

    def handle_multiline_comment(stripped_line)
      @comments << [@line_number, stripped_line]
      @in_multiline_comment = false if stripped_line == "=end"
    end

    def handle_heredoc(line, stripped_line)
      @result_lines << line.rstrip
      @in_heredoc, @heredoc_delimiter = self.class.update_heredoc_state(
        stripped_line, @heredoc_delimiter
      )
    end

    def handle_regular_line(line, stripped_line)
      if stripped_line == "=begin"
        start_multiline_comment(stripped_line)
      elsif (heredoc_start = self.class.detect_heredoc_start(line))
        start_heredoc(line, heredoc_start)
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
      code_part, comment_part = self.class.split_line(line)
      @comments << [@line_number, comment_part.strip] if comment_part
      return if code_part.strip.empty?

      @result_lines << code_part.rstrip
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/BlockNesting
    def self.split_line(line)
      in_single_quote = false
      in_double_quote = false
      in_regex = false
      escape = false
      index = 0

      while index < line.length
        char = line[index]

        if escape
          escape = false
        else
          case char
          when "\\"
            escape = true
          when "'"
            in_single_quote = !in_single_quote unless in_double_quote || in_regex
          when '"'
            in_double_quote = !in_double_quote unless in_single_quote || in_regex
          when "/"
            if in_regex
              in_regex = false
            elsif !in_single_quote && !in_double_quote &&
                  preceding_char_is_operator?(line, index)
              in_regex = true
            end
          when "#"
            result = handle_comment_character(line, index, in_single_quote, in_double_quote, in_regex)
            return result if result
          end
        end
        index += 1
      end
      [line, nil]
    end

    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/BlockNesting

    def self.handle_comment_character(line, index, in_single_quote, in_double_quote, in_regex)
      unless in_single_quote || in_double_quote || in_regex
        code_part = line[0...index]
        comment_part = line[index..]
        return [code_part, comment_part]
      end
      nil
    end

    def self.update_heredoc_state(stripped_line, heredoc_delimiter)
      if stripped_line == heredoc_delimiter
        [false, nil]
      else
        [true, heredoc_delimiter]
      end
    end

    def self.detect_heredoc_start(line)
      if (match = line.match(/<<[-~]?(["'`]?)(\w+)\1/))
        match[2]
      end
    end

    def self.preceding_char_is_operator?(line, index)
      return true if index.zero?

      prev_char = line[index - 1]
      prev_char =~ %r{[\s(,=+\-*/%|&!<>?:]}
    end
  end
end
