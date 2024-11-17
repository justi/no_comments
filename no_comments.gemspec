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
  spec.required_ruby_version = ">= 3.2.4"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.executables << "no_comments"
  spec.require_paths = ["lib"]

  spec.metadata["rubygems_mfa_required"] = "true"
end
