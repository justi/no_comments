# frozen_string_literal: true

module NoComments
  module LineParser
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/BlockNesting
    def split_line(line)
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

    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/BlockNesting
    def handle_comment_character(line, index, in_single_quote, in_double_quote, in_regex)
      unless in_single_quote || in_double_quote || in_regex
        code_part = line[0...index]
        comment_part = line[index..]
        return [code_part, comment_part]
      end
      nil
    end

    def update_heredoc_state(stripped_line, heredoc_delimiter)
      if stripped_line == heredoc_delimiter
        [false, nil]
      else
        [true, heredoc_delimiter]
      end
    end

    def detect_heredoc_start(line)
      if (match = line.match(/<<[-~]?(["'`]?)(\w+)\1/))
        match[2]
      end
    end

    def preceding_char_is_operator?(line, index)
      idx = index - 1
      idx -= 1 while idx >= 0 && line[idx] =~ /\s/
      return true if idx.negative?
      return true if line[idx - 1..idx] == "::"

      prev_char = line[idx]
      operator_chars = %w[\[ = + - * / % | & ! < > ^ ~ ( , ? : ; {]
      operator_chars.include?(prev_char)
    end
  end
end
