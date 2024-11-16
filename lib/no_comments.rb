# frozen_string_literal: true

require "no_comments/version"
require "ripper"

module NoComments
  class Remover
    def self.clean(file_path, audit: false)
      if File.directory?(file_path)
        Dir.glob("#{file_path}/**/*.rb").each do |file|
          process_file(file, audit: audit)
        end
      else
        process_file(file_path, audit: audit)
      end
    end

    def self.process_file(file_path, audit: false)
      validate_file_extension(file_path)
      file_content = File.read(file_path)

      if audit
        audit_comments(file_path, file_content)
      else
        content_cleaned = remove_comments(file_content)
        File.write(file_path, content_cleaned)
      end
    end

    def self.validate_file_extension(file_path)
      raise "Only Ruby files are supported" unless file_path.end_with?(".rb")
    end

    def self.audit_comments(file_path, content)
      comments = extract_comments(content)
      puts "File: #{file_path}" unless comments.empty?

      comments.each do |(pos, _, tok, _)|
        line, = pos
        puts "  Line #{line}: #{tok.strip}"
      end
    end

    def self.remove_comments(content)
      comments = extract_comments(content)
      content = process_comments(content, comments)
      remove_empty_lines(content)
    end

    def self.extract_comments(content)
      Ripper.lex(content).select { |_pos, type, _tok, _| type == :on_comment }
    end

    def self.process_comments(content, comments)
      comments.sort_by { |(pos, _, _, _)| [pos[0], pos[1]] }.reverse.each do |(pos, _, _, _)|
        line, col = pos
        lines = content.lines
        lines[line - 1] = process_comment_line(lines[line - 1], col)
        content = lines.join
      end
      content
    end

    def self.process_comment_line(line, col)
      if line[col..].strip.start_with?("#")
        "#{line[0...col].rstrip}\n"
      else
        "\n"
      end
    end

    def self.remove_empty_lines(content)
      content.gsub(/^\s*$\n/, "")
    end
  end
end
