# Liturgical Law

This directory contains documents of liturgical legislation
implemented by the library. Each document is reproduced in Latin,
in a form of a Markdown file.
If the document contains blocks of Ruby code, these are not part
of the liturgical law, but contain code examples proving
that the immediately preceding part of the document is implemented
by the library.

```ruby
# RSpec expectations are available in the code blocks
expect(1).to be_truthy

# method `year` returns a random year (the same for the whole example, even if called multiple times)
# and should be used in all examples which need a single year and don't require a particular one
expect(year).to be_a Integer
expect(year).to be >= 1970

a = year; b = year
expect(a).to be b

# method `years` returns an Enumerable of years (which are valid liturgical years
# for calendarium-romanum)
expect(years).to be_a Enumerable
yrs = years.to_a
expect(yrs[0]).to be_a Integer

# method `years_with` returns an array of years (which are valid liturgical years
# for calendarium-romanum) matching the specified condition
yrs = years_with {|y| true }
expect(yrs).to be_an Array
expect(yrs[0]).to be_an Integer
# if no matching year is found an exception is raised
expect { years_with {|y| false } }
  .to raise_exception(RuntimeError, /no matching year/)
```
