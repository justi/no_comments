# Cleanio

`cleanio` is a simple Ruby gem that removes comments from `.rb` files. It can handle single-line comments and inline comments, leaving your code clean and readable.

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

To install `cleanio`, add it to your Gemfile:

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
Alternatively, you can use the command line tool:

```bash
cleanio -f path/to/your_file.rb
```
This will remove all comments from the specified Ruby file.

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
- Option to stay documentation comments (e.g. `# @param`) https://www.rubydoc.info/gems/rubocop/RuboCop/Cop/Style/Documentation
- Option to recursively clean all files in a directory
- Option to clean all files in a directory except for a specified file
- Option for audit mode (show what would be removed without actually removing it)
