# Rake Integration

This guide explains how to run sus tests from a Rake task.

## Setup

Rake is not a dependency of sus, so add it to your project's `gems.rb` (or `Gemfile`) if it isn't already there:

``` ruby
gem "rake"
```

Then define a test task in your `Rakefile`:

``` ruby
require "sus/rake"

Sus::Rake::TestTask.new

task default: :test
```

Running `rake test` (or just `rake`) runs every test matching `test/**/*.rb`, using your project's `config/sus.rb` if present, the same as `sus` does. The task fails if any test fails.

## Configuration

You can pass a task name and configure the task using a block:

``` ruby
Sus::Rake::TestTask.new(:fast) do |task|
	task.paths = ["test/my_gem/parser.rb", "test/my_gem/lexer.rb:12"]
	task.verbose = true
end
```

  - `paths` limits the run to specific test files, optionally with a `:line` suffix to select a single test or context. All tests are run by default.
  - `verbose` prints each test as it runs. Verbose output is also enabled by `rake --verbose`, by setting `SUS_VERBOSE=true`, or when a CI provider is running in debug mode.

The tests run inside the Rake process. Use `bundle exec sus` directly when you need command line arguments, or `sus-parallel` when you want to run tests in parallel.
