# frozen_string_literal: true

module NoComments
  module CommentDetector
    MAGIC_COMMENT_REGEX = /\A#.*\b(?:frozen_string_literal|encoding|coding|warn_indent|fileencoding)\b.*\z/
    TOOL_COMMENT_REGEX = /\A#\s*(?:rubocop|reek|simplecov|coveralls|pry|byebug|noinspection|sorbet|type)\b/
    DOC_COMMENT_REGEX = /\A#\s*@\w+/
    NODOC_STRING = ":nodoc:"
    CLASS_OR_MODULE_REGEX = /\A(?:class|module)\b/
    def magic_comment?(stripped_line)
      stripped_line.match?(MAGIC_COMMENT_REGEX)
    end

    def tool_comment?(stripped_line)
      stripped_line.match?(TOOL_COMMENT_REGEX)
    end

    def documentation_comment?(stripped_line, next_line = nil)
      return true if stripped_line.match?(DOC_COMMENT_REGEX)
      return true if stripped_line.include?(NODOC_STRING)
      return true if next_line&.match?(CLASS_OR_MODULE_REGEX)

      false
    end
  end
end
