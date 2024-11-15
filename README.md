# Cleanio

`Cleanio` is a simple Ruby gem that removes comments from `.rb` files. It can handle single-line comments and inline comments, leaving your code clean and readable.

---

## Table of Contents

1. [Installation](#installation)
2. [Usage](#usage)
3. [Testing](#testing)
4. [Contribution](#contribution)
5. [License](#license)
6. [TODO](#todo)

---

## Installation

To install `Cleanio`, add it to your Gemfile:

```ruby
gem 'cleanio'
```
Then execute:

```bash
bundle install
```
Or install it yourself using the following command:

```bash
gem install cleanio
```


## Usage
To clean up comments from a .rb file, simply run:

```ruby
require 'cleanio'

Cleanio::Remover.clean('path/to/your_file.rb')
```
### Audit Mode

To use the audit mode, pass the `audit: true` flag to the `clean` method. This will output the file paths and lines containing comments without modifying the file.

#### Example

```ruby
Cleanio::Remover.clean('example.rb', audit: true)
```
#### Output

```bash
File: example.rb
  Line 1: # This is a comment
  Line 3: # Another comment
```

### Command-Line Interface (CLI)

You can use Cleanio directly from the command line to clean or audit `.rb` files.

#### Clean Comments

To remove comments from a file, use:

```bash
cleanio -f path/to/file.rb
```
#### Audit mode

To run Cleanio in audit mode without modifying files, use the `--audit` flag:

```bash
cleanio -f path/to/file.rb --audit
```

## Testing
Cleanio uses RSpec for testing. To run the tests, first make sure all dependencies are installed:

```bash
bundle install
```
Then, run the tests with:

```bash
bundle exec rspec
```
All tests are located in the spec directory and cover the main functionality of the gem, ensuring it properly removes comments from Ruby files.

## Contribution

Bug reports and pull requests are welcome on GitHub at https://github.com/justi/cleanio.

To contribute:

Fork the repository.
Create a new branch (git checkout -b feature-branch).
Make your changes.
Commit your changes (git commit -m 'Add new feature').
Push to the branch (git push origin feature-branch).
Open a pull request.

Please ensure that your code follows the existing style and that all tests pass.

## License
The gem is available as open source under the terms of the MIT License.


## TODO
- Add support multi-line comments (`=begin`...`=end`)
- Add support to magic comments (e.g. `# frozen_string_literal: true`) https://docs.ruby-lang.org/en/3.2/syntax/comments_rdoc.html - thanks [Chris](https://github.com/khasinski)!
- Option to stay documentation comments (e.g. `# @param`) https://www.rubydoc.info/gems/rubocop/RuboCop/Cop/Style/Documentation
- Option to recursively clean all files in a directory
- Option to clean all files in a directory except for a specified file
