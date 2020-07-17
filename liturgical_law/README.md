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
```
