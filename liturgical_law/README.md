# Liturgical Law

This directory contains documents of liturgical legislation
implemented by the library. Each document is reproduced in Latin,
in a form of a Markdown file.

## Main documents, development overview

Fundamental outline of the calendar system is contained in the document
*Normae universales de anno liturgico et de calendario*, first published in 1969.
Most of the 1969 text is in force without a substantial change up to this day,
but during the years some important parts were changed, a particularly hot matter
being the rules concerning transfer of impeded solemnities.
Apart of updates of the *Normae* themselves, a few additional rules were added
to the calendar system by separate documents (the more formal ones being CDW decrees,
the less formal ones notifications).

* **1969 Normae universales de anno liturgico et de calendario**
  initial outline of the calendar system
* **1970 Missale Romanum, editio typica**
  [updated](http://www.cultodivino.va/content/dam/cultodivino/notitiae/1970/54%201.pdf#page=49)
  paragraphs 13, 56, 59 and 60 of the *Normae*
* **1975 Missale Romanum, editio typica altera**
  [updated](http://www.cultodivino.va/content/dam/cultodivino/notitiae/1975/111-112.pdf#page=27)
  paragraphs 14, 47 and 59 of the *Normae* (mostly mere terminological changes;
  the change of paragraph 59 dropped a few categories from the *Table of Liturgical Days*)
* **1977 Decree about the feast of Baptism of the Lord**
  with an improved rule of computing its date for places where Epiphany is celebrated
  on Sunday
* **1990 Decree updating Normae, n. 5**
  (transfer rule for a solemnity impeded by a privileged Sunday)
* **1998 Notification concerning occurrence of the memorial of the Immaculate Heart of Mary**

## Code examples

The Markdown files, in addition to the text of liturgical
legislation, contain also blocks of Ruby code, each demonstrating
that the immediately preceding part of the document is implemented
by the library. The documents illustrated with code blocks thus constitute
a test suite in the [literate programming](https://en.wikipedia.org/wiki/Literate_programming)
style. This test suite is integrated in the project's main test suite
(see `spec/liturgical_law_spec.rb`)

Utilities commonly used in the code blocks:

```ruby
# RSpec expectations are available in the code blocks
expect(1).to be_truthy

# method `year` returns a random year (which is a valid liturgical year
# for calendarium-romanum) and should be used in all examples which need
# a single year and don't require a particular one
expect(year).to be_an Integer
expect(year).to be >= 1970
# year is the same for the whole example, even if called multiple times
a = year; b = year
expect(a).to be b

# method `years` returns a representative Enumerable of (valid liturgical)
# years and should be used in all examples which test across several years
# and don't require particular ones
expect(years).to be_an Enumerable
yrs = years.to_a
expect(yrs).to all(be_an(Integer))

# method `years_with` returns an array of years (which are valid liturgical years
# for calendarium-romanum) matching the specified condition
yrs = years_with {|y| true }
expect(yrs).to be_an Array
expect(yrs).to all(be_an(Integer))
# if no matching year is found an exception is raised
expect { years_with {|y| false } }
  .to raise_exception(RuntimeError, /no matching year/)
```
