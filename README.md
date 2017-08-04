# calendarium-romanum

[![Build Status](https://travis-ci.org/igneus/calendarium-romanum.svg?branch=master)](https://travis-ci.org/igneus/calendarium-romanum)
[![Gem Version](https://badge.fury.io/rb/calendarium-romanum.svg)](https://badge.fury.io/rb/calendarium-romanum)

[API documentation](http://www.rubydoc.info/github/igneus/calendarium-romanum/master)

Ruby gem for
calendar computations according to the Roman Catholic liturgical
calendar as instituted by
[MP Mysterii Paschalis](http://w2.vatican.va/content/paul-vi/en/motu_proprio/documents/hf_p-vi_motu-proprio_19690214_mysterii-paschalis.html) of Paul VI. (AAS 61 (1969), pp. 222-226).
The rules are defined in General Norms for the Liturgical Year
and the Calendar
([English translation](https://www.ewtn.com/library/CURIA/CDWLITYR.HTM)).

## Features

- [x] liturgical season
- [x] Sundays, temporale feasts
- [x] sanctorale calendars: data format, example data files, their loading
- [x] resolution of precedence of concurrent celebrations
- [x] octave days
- [x] commemorations in the privileged seasons where memorials are suppressed
- [x] transfer of suppressed solemnities
- [x] additional temporale feasts (Christ the Eternal Priest and similar)
- [ ] optional transfer of important solemnities to a nearby Sunday

## Credits

includes an important bit of code from the
[easter](https://github.com/jrobertson/easter) gem
by James Robertson

## License

freely choose between GNU/LGPL 3 and MIT

## Basic Usage

For more self-explaining, commented and copy-pastable
examples see the [examples directory](./examples/).

All the examples below expect that you first required the gem:

```ruby
require 'calendarium-romanum'
```

### 1. What liturgical season is it today?

```ruby
calendar = CalendariumRomanum::Calendar.for_day(Date.today)
day = calendar.day(Date.today)
day.season # => #<CalendariumRomanum::Season:0x000000029e1a40 @symbol=:ordinary, @colour=#<CalendariumRomanum::Colour:0x000000029e1f68 @symbol=:green>>
```

`Day#season` returns a `Season` instance representing
the current liturgical season.

### 2. What liturgical day is it today?

`Day` has several other properties.
`Day#celebrations` returns an `Array` of `Celebration`s
that occur on the given day. Usually the `Array` has a single
element, but in case of optional celebrations (several optional
memorials occurring on a ferial) it may have two or more.

```ruby
date = Date.new(2016, 8, 19)
calendar = CalendariumRomanum::Calendar.for_day(date)
day = calendar.day(date)
day.celebrations # => [#<CalendariumRomanum::Celebration:0x0000000250fdf0 @title="Friday, 20th week in Ordinary Time", @rank=#<CalendariumRomanum::Rank:0x000000029e1108 @priority=3.13, ... >, @colour=#<CalendariumRomanum::Colour:0x000000029e1f68 @symbol=:green>>]
```

In this case the single `Celebration` available is a ferial,
described by it's title, rank and liturgical
colour.

### 3. But does it take feasts of saints in account?

Actually, no. Not yet. We need to load some calendar data first:

```ruby
CR = CalendariumRomanum
loader = CR::SanctoraleLoader.new
sanctorale = loader.load_from_file 'data/universal-en.txt' # insert path to your data file
date = Date.new(2016, 8, 19)
calendar = CR::Calendar.for_day(date, sanctorale)
day = calendar.day(date)
day.celebrations # => [#<CalendariumRomanum::Celebration:0x000000027d9590 @title="Friday, 20th week in Ordinary Time", @rank=#<CalendariumRomanum::Rank:0x000000029e1108 @priority=3.13, ... >, @colour=#<CalendariumRomanum::Colour:0x000000029e1f68 @symbol=:green>>, #<CalendariumRomanum::Celebration:0x000000029c96c0 @title="Saint John Eudes, priest", @rank=#<CalendariumRomanum::Rank:0x000000029e1180 @priority=3.12, ... >, @colour=#<CalendariumRomanum::Colour:0x000000029e1f18 @symbol=:white>>]
```

(Note how we saved some typing by defining new constant `CR`
referencing the `CalendariumRomanum` module.)

Unless a sanctorale is loaded, `Calendar` only counts with
temporale feasts, Sundays and ferials.

### 4. Isn't there an easier way to get sanctorale data?

Yes! There are a few data files bundled in the gem.
You can explore them by iterating over `CalendariumRomanum::Data.all`.
The more interesting ones are additionally identified by their proper
constants, e.g. `CalendariumRomanum::Data::GENERAL_ROMAN_ENGLISH`.
Bundled data files can be loaded by a handy shortcut method `#load`:

```ruby
CR = CalendariumRomanum
sanctorale = CR::Data::GENERAL_ROMAN_ENGLISH.load # easy loading
date = Date.new(2016, 8, 19)
calendar = CR::Calendar.for_day(date, sanctorale)
day = calendar.day(date)
```

## Sanctorale Data

### Use prepared data or create your own

The gem expects data files following a custom format -
see README in the [data](/data) directory for it's description.
The same directory contains a bunch of example data files.

`universal-en.txt` and `universal-la.txt` are data of the General
Roman Calendar in English and Latin.

The other files, when layered properly, can be used to assemble
proper calendar of any diocese in the Czech Republic.

### Implement custom loading strategy

In case you already have sanctorale data in another format,
it might be better suited for you to implement your own loading
routine instead of migrating them to our custom format.
`SanctoraleLoader` is the class to look into for inspiration.

The important bit is that for each celebration you
build a `Celebration` instance and push it in a `Sanctorale`
instance by a call to `Sanctorale#add`, which receives a month,
a day (as integers) and a `Celebration`:

```ruby
include CalendariumRomanum
sanctorale = Sanctorale.new
celebration = Celebration.new('Saint John Eudes, priest', Ranks::MEMORIAL_OPTIONAL, Colours::WHITE)
sanctorale.add 8, 19, celebration

date = Date.new(2016, 8, 19)
calendar = Calendar.for_day(date, sanctorale)

day = calendar.day(date)
day.celebrations # => [#<CalendariumRomanum::Celebration:0x000000010deea8 @title="", @rank=#<struct CalendariumRomanum::Rank priority=3.13, desc="Unprivileged ferials", short_desc="ferial">, @colour=:green>, #<CalendariumRomanum::Celebration:0x000000010fec08 @title="Saint John Eudes, priest", @rank=#<struct CalendariumRomanum::Rank priority=3.12, desc="Optional memorials", short_desc="optional memorial">, @colour=:white>]
```

(Note that this time some typing was saved by *including*
the `CalendariumRomanum` module into the current namespace.)

## I18n, or, how to fix names of temporale feasts

One drawback of the current implementation is that names
of *temporale* feasts are totally independent of *sanctorale* feast
names. They are hardcoded in the gem, as [i18n][]
[translation strings][translations].

When you load *sanctorale* data in your favourite language,
the `Calendar` will by default still produce *temporale*
feasts with names in English.
This can be fixed by changing locale to match your *sanctorale*
data.

`I18n.locale = :la # or :it, :cs`

The gem ships with English, Latin, Italian and Czech translation.
Contributed translations to other languages are most welcome.

## Custom movable feasts

Some local calendars may include proper movable feasts.
In Czech Republic this has recently been the case with the newly
introduced feast of *Christ the Priest* (celebrated on Thursday
after Pentecost).

This feast, by it's nature, extends the cycle of
*Feasts of the Lord in the Ordinary Time* and thus belongs
to the *temporale.* Please note that even if your proper movable feast
is by it's nature a *sanctorale* feast, only having a movable
date, the only way to handle it with this gem is to write
a *temporale* extension. There is no support for movable feasts
in the `Sanctorale` class. Even the single movable sanctorale
feast of the General Roman Calendar,
the memorial of *Immaculate Heart of Mary,* is, by a little cheat,
currently implemented in the `Temporale`.

Temporale extensions are implemented as mixin modules
which can be included in subclasses of `Temporale`.
The sole responsibility of such a module is to define
callback method [included][module-included]
and in this call `add_celebration` method of the receiving
`Temporale` class at least once.

```ruby
CR = CalendariumRomanum

module MyExtension
  # registers celebration defined by the extension
  def self.included(mod)
    mod.add_celebration(
      :my_feast_date, # name of a method computing date of the feast
      CR::Ranks::FEAST_PROPER, # rank
      CR::Colours::WHITE, # colour
      'My Feast' # feast title
    )

    # It is possible to use a Proc as feast title if you want it
    # to be determined at runtime - e.g. because you want to
    # have the feast title translated follow changes of `I18n.locale`
    mod.add_celebration(
      :another_feast_date,
      CR::Ranks::MEMORIAL_PROPER,
      CR::Colours::WHITE,
      proc { I18n.t('my_feasts.another_feast') }
    )
  end

  # computes date of the feast
  def my_feast_date
    # Let the feast fall on Saturday before Christ the King.
    # All Temporale instance methods can be used for the computation.
    christ_king - 1
  end

  def another_feast_date
    easter_sunday + 9
  end
end

# create Temporale subclass with the extension, instantiate it
extended_temporale_cls = CR::Temporale.with_extensions(MyExtension)
temporale = extended_temporale_cls.new(2016)

# the feast is there!
temporale.get(Date.new(2017, 11, 25)) # => #<CalendariumRomanum::Celebration:0x0000000246fd78 @title="My Feast", @rank=#<CalendariumRomanum::Rank:0x000000019c27e0 @priority=2.8, ... >, @colour=#<CalendariumRomanum::Colour:0x000000019c31e0 @symbol=:white>>
```

## How to run tests

Get the sources, install development dependencies

`bundle install`

then execute tests with

`rake spec`

See also `.travis.yml` for comprehensive tests run on the CI.

[i18n]: https://github.com/svenfuchs/i18n
[translations]: /tree/master/config/locales
[module-included]: http://ruby-doc.org/core-2.2.2/Module.html#method-i-included
