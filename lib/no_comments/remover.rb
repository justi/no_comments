# frozen_string_literal: true

require "no_comments/version"
require "no_comments/content_processor"
module NoComments
  class Remover
    def self.clean(file_path, audit: false, keep_doc_comments: false)
      if File.directory?(file_path)
        Dir.glob("#{file_path}/**/*.rb").each do |file|
          process_file(file, audit: audit, keep_doc_comments: keep_doc_comments)
        end
      else
        process_file(file_path, audit: audit, keep_doc_comments: keep_doc_comments)
      end
    end

    def self.process_file(file_path, audit: false, keep_doc_comments: false)
      validate_file_extension(file_path)
      content = File.read(file_path)
      processor = ContentProcessor.new(keep_doc_comments: keep_doc_comments)
      cleaned_content, comments = processor.process(content)
      if audit
        print_audit(file_path, comments)
      else
        File.write(file_path, cleaned_content)
      end
    end

    def self.validate_file_extension(file_path)
      raise "Only Ruby files are supported" unless file_path.end_with?(".rb")
    end

    def self.print_audit(file_path, comments)
      return if comments.empty?

      puts "File: #{file_path}"
      comments.each do |line_number, comment_text|
        puts "  Line #{line_number}: #{comment_text}"
      end
    end
  end
end
