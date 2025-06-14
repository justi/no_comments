# frozen_string_literal: true

require_relative "lib/no_comments/version"

Gem::Specification.new do |spec|
  spec.name = "no_comments"
  spec.version = NoComments::VERSION
  spec.authors = ["Justyna"]
  spec.email = ["justine84@gmail.com"]

  spec.summary = "NoComments is a Ruby gem designed to clean up .rb files by removing unnecessary comments,
leaving your code clean and ready for deployment."
  spec.homepage = "https://github.com/justi/no_comments"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4.4"

  spec.metadata = {
    "source_code_uri" => "https://github.com/justi/no_comments",
    "homepage_uri" => spec.homepage,
    "rubygems_mfa_required" => "true"
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  require "open3"
  gemspec = File.basename(__FILE__)
  output, = Open3.capture2("git", "ls-files", "-z", chdir: __dir__)
  spec.files = output.split("\x0").reject do |f|
    (f == gemspec) ||
      f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.executables << "no_comments"
  spec.require_paths = ["lib"]
end
