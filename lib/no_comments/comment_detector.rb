# frozen_string_literal: true

# lib/no_comments/comment_detector.rb

module NoComments
  module CommentDetector
    MAGIC_COMMENT_REGEX = /\A#.*\b(?:frozen_string_literal|encoding|coding|warn_indent|fileencoding)\b.*\z/
    TOOL_COMMENT_REGEX = /\A#\s*(?:rubocop|reek|simplecov|coveralls|pry|byebug|noinspection|sorbet|type)\b/

    def magic_comment?(stripped_line)
      stripped_line.match?(MAGIC_COMMENT_REGEX)
    end

    def tool_comment?(stripped_line)
      stripped_line.match?(TOOL_COMMENT_REGEX)
    end
  end
end
