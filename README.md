# calendarium-romanum

[![Build Status](https://travis-ci.org/igneus/calendarium-romanum.svg?branch=master)](https://travis-ci.org/igneus/calendarium-romanum)
[![Gem Version](https://badge.fury.io/rb/calendarium-romanum.svg)](https://badge.fury.io/rb/calendarium-romanum)

[API documentation](http://www.rubydoc.info/github/igneus/calendarium-romanum/master)

Ruby gem for
calendar computations according to the Roman Catholic liturgical
calendar as instituted by
MP Mysterii Paschalis of Paul VI. ([AAS 61 (1969)](http://www.vatican.va/archive/aas/documents/AAS-61-1969-ocr.pdf), pp. 222-226).
The rules are defined in General Norms for the Liturgical Year
and the Calendar
([English translation](https://www.ewtn.com/library/CURIA/CDWLITYR.HTM)).

## Features

- [x] liturgical season
- [x] Sundays, temporale feasts
- [x] sanctorale calendars: data format, example data files, their loading
- [x] resolution of precedence of concurrent celebrations
- [x] octave days
- [ ] commemorations in the privileged seasons where memorials are suppressed
- [x] transfer of suppressed solemnities
- [ ] additional temporale feasts (Christ the Eternal Priest and similar)
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
day.season # => :ordinary
```

`Day#season` returns a `Symbol` representing the current liturgical
season.

### 2. What liturgical day is it today?

`Day` has several other properties.
`Day#celebrations` returns an `Array` of `Celebration`s
that occur on the given day. Usually the `Array` has a single
element, but in case of optional celebrations (several optional
memorials occurring on a ferial) it may have two or more.

```ruby
day.celebrations # => [#<CalendariumRomanum::Celebration:0x00000001741c78 @title="", @rank=#<struct CalendariumRomanum::Rank priority=3.13, desc="Unprivileged ferials", short_desc="ferial">, @colour=:green>]
```

In this case the single `Celebration` available is a ferial,
described by it's title (empty in this case), rank and liturgical
colour.

### 3. But does it take feasts of saints in account?

Actually, no. Not yet. We need to load some calendar data first:

```ruby
sanctorale = CalendariumRomanum::Sanctorale.new
loader = CalendariumRomanum::SanctoraleLoader.new
loader.load_from_file sanctorale, 'data/universal-en.txt' # insert path to your data file
calendar = CalendariumRomanum::Calendar.for_day(Date.today, sanctorale)
day = calendar.day(Date.new(2016, 8, 19))
day.celebrations # => [#<CalendariumRomanum::Celebration:0x000000016ed330 @title="", @rank=#<struct CalendariumRomanum::Rank priority=3.13, desc="Unprivileged ferials", short_desc="ferial">, @colour=:green>, #<CalendariumRomanum::Celebration:0x00000001715790 @title="Saint John Eudes, priest", @rank=#<struct CalendariumRomanum::Rank priority=3.12, desc="Optional memorials", short_desc="optional memorial">, @colour=:white>]
```

Unless a sanctorale is loaded, `Calendar` only counts with
temporale feasts, Sundays and ferials.

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
calendar = Calendar.for_day(Date.today, sanctorale)
```

Now our `Sanctorale` knows one feast and the `Calendar` resolves
it correctly:

```ruby
day = calendar.day(Date.new(2016, 8, 19))
day.celebrations # => [#<CalendariumRomanum::Celebration:0x000000010deea8 @title="", @rank=#<struct CalendariumRomanum::Rank priority=3.13, desc="Unprivileged ferials", short_desc="ferial">, @colour=:green>, #<CalendariumRomanum::Celebration:0x000000010fec08 @title="Saint John Eudes, priest", @rank=#<struct CalendariumRomanum::Rank priority=3.12, desc="Optional memorials", short_desc="optional memorial">, @colour=:white>]
```
