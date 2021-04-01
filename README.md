# Textrepo

[![Build Status](https://github.com/mnbi/textrepo/workflows/Build/badge.svg)](https://github.com/mnbi/textrepo/actions?query=workflow%3A"Build")
[![CodeFactor](https://www.codefactor.io/repository/github/mnbi/textrepo/badge)](https://www.codefactor.io/repository/github/mnbi/textrepo)

Textrepo is a repository to store a note with a timestamp.  Each note
in the repository operates with the associated timestamp.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'textrepo'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install textrepo

## Usage

Here is a very short sample to use `textrepo`.  It will make
`~/textrepo_sample` directory and store some text into it.

``` ruby
#!/usr/bin/env ruby

require "textrepo"

conf = {
  :repository_type => :file_system,
  :repository_name => "textrepo_sample",
  :repository_base => File.expand_path("~"),
}

repo = Textrepo.init(conf)

t0 = Time.now

stamps = []
stamps << repo.create(Textrepo::Timestamp.new(t0), ["jan", "feb", "mar"])
stamps << repo.create(Textrepo::Timestamp.new(t0, 1), ["apr", "may", "jun"])
stamps << repo.create(Textrepo::Timestamp.new(t0, 2), ["jul", "aug", "sep"])
stamps << repo.create(Textrepo::Timestamp.new(t0, 3), ["oct", "nov", "dec"])

entries = repo.notes
puts entries

stamps.each { |stamp|
  text = repo.read(stamp)
  puts "----"
  puts stamp
  puts text
}
```

Also see `examples` directory.  There is a small tool to demonstrate
how to use `textrepo`.

## What is TEXT?

In macOS (or similar unix OS), text is a date stored into a regular
file.  Its characteristics are;

- a character stream coded in some encoding system (such UTF-8),
- divided into multiple physical lines with newline character (`\n`).

In `textrepo` and its client program, a **text** is usually generated
from a text file mentioned above.  It is;

- a character stream coded in UTF-8,
- consists of multiple logical lines (each of them does not contain a
  newline character).

That is, newline characters are removed when text is read from a file
and added appropriately when it is written into a file.

So, **text** is represented with Ruby objects as follows:

- **Text** is represented with an `Array` object which contains
  multiple `String` objects.
- A `String` object represents a **logical line** of **text**.
- Each `String` does not contain a newline character.
- An empty string ("") represents a empty line.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mnbi/textrepo.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
