# NoComments
NoComments is a Ruby gem designed to clean up `.rb` files by removing unnecessary comments, leaving your code clean and ready for deployment.

## What This Gem Does
It removes:

- Single-line comments (e.g., # This is a comment)
- Block comments (e.g., =begin ... =end)
- Inline comments (e.g., puts 'Hello' # This is a comment)

It preserves:

- Shebangs (e.g., #!/usr/bin/env ruby)
- Magic comments (e.g., # frozen_string_literal: true)
- Tool-defined comments (e.g., # rubocop:disable all)

## Table of Contents
1. [When to Use This Gem](#When-to-Use-This-Gem)
2. [When Not to Use This Gem](#When-Not-to-Use-This-Gem)
3. [Installation](#Installation)
4. [Usage](#Usage)
   - [Audit Mode](#Audit-Mode)
   - [CLI](#CLI)
5. [Testing](#Testing)
6. [Contributing](#Contributing)
7. [License](#License)
8. [TODO](#TODO)

## When to Use This Gem

NoComments is particularly useful in the following scenarios:

- **Auto-Generated or Boilerplate Code:** Helps clean up scaffolding or boilerplate comments, commonly generated in frameworks like Rails.
- **Codebases with Overused Comments:** Removes redundant comments that restate obvious code.
- **Continuous Integration/Code Review Workflows:** Automates comment cleanup during CI/CD processes.
- **Educational Projects:** Streamlines code by removing teaching-related comments after the learning phase.
- **Maintaining Open Source Projects:** Ensures consistency by removing unnecessary comments in contributions.

## When Not to Use This Gem

While the gem is powerful, it may not be suitable in these scenarios:

- **Code with Valuable Documentation Comments:** Avoid using the gem if your code relies on comments for explaining complex logic or business rules.
- **Codebases Requiring Compliance:** In regulated industries, where specific comments are required for audits or documentation purposes.
- **Highly Dynamic Environments:** In fast-changing projects, comments might provide crucial context for recent changes or decisions.

## Installation

To install no_comments, add it to your Gemfile:

```ruby
gem 'no_comments'
```
Then execute:

```bash
bundle install
```

Or install directly:

```bash
gem install no_comments
```

## Usage

### Cleaning Files or Directories
To clean up comments from a `.rb` file or an entire directory, use the `NoComments::Remover.clean` method:

```ruby
require 'no_comments'

# Clean a single file
NoComments::Remover.clean('path/to/your_file.rb')

# Clean all `.rb` files in a directory
NoComments::Remover.clean('path/to/your_directory')
```
### Audit Mode
Audit mode allows you to preview the comments that would be removed without modifying the files. Use the `audit: true` flag with the `clean` method:

```ruby
NoComments::Remover.clean('example.rb', audit: true)
```
#### Example Output:
`example.rb`:
```ruby
# This is a comment
def hello
  puts 'Hello' # Another comment
end
```
Output:
```bash
File: example.rb
  Line 1: # This is a comment
  Line 3: # Another comment
```

### CLI
`NoComments` provides a Command Line Interface (CLI) for easy comment cleanup. The CLI supports the following options:

#### Clean Comments:
```bash
no_comments -p path/to/file.rb
no_comments -p path/to/directory
```
#### Audit Mode:
```bash
no_comments -p path/to/file.rb --audit
no_comments -p path/to/directory --audit
```

## Testing

This gem uses RSpec for testing. To run tests:

1. Install dependencies:
```bash
bundle install
```
2. Run the test suite::
```bash
bundle exec rspec
```

Tests are located in the spec directory and ensure that the gem behaves as expected, removing comments appropriately while preserving essential ones.

## Contributing
We welcome contributions! To contribute:

1. Fork the repository.
2. Create a new branch for your feature or fix:
```bash
git checkout -b feature-branch
```
3. Make your changes.
4. Commit your changes with a descriptive message:
```bash
git commit -m 'Add new feature'
```
5. Push your branch:
```bash
git push origin feature-branch
```
6. Open a pull request on GitHub.

Please ensure your code follows the existing style and that all tests pass before submitting.

## License
This gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## TODO
Planned features for future updates:
- **Option to Keep Documentation Comments:**
  - Preserve comments like # @param or # @return for tools like YARD.
  Reference: [RuboCop documentation cop](https://www.rubydoc.info/gems/rubocop/RuboCop/Cop/Style/Documentation).
- **Selective Cleaning:**
  - Allow users to clean all files in a directory except for specified ones.

---
## Why Use NoComments?
NoComments is the perfect tool for keeping your codebase clean and focused, whether you're starting fresh or maintaining an existing project. By automating comment cleanup, you can focus on what matters: writing great code.
