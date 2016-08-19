# calendarium-romanum

[API documentation](http://www.rubydoc.info/github/igneus/calendarium-romanum/master)

Ruby gem for
calendar computations according to the Roman Catholic liturgical
calendar as instituted by
MP Mysterii Paschalis of Paul VI. (AAS 61 (1969), pp. 222-226).

## Status

Handles most of the calendar logic (with an important exception of resolving
collisions of solemnities).

Needs thorough testing and more [data files](data/).

## Credits

includes an important bit of code from the
[easter](https://github.com/jrobertson/easter) gem
by James Robertson

## License

freely choose between GNU/LGPL 3 and MIT

## Usage

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
loader = CalendariumRomanum::SanctoraleLoader.new
loader.load_from_file calendar.sanctorale, 'data/universal-en.txt'
day = calendar.day(Date.new(2016, 8, 19))
day.celebrations # => [#<CalendariumRomanum::Celebration:0x000000016ed330 @title="", @rank=#<struct CalendariumRomanum::Rank priority=3.13, desc="Unprivileged ferials", short_desc="ferial">, @colour=:green>, #<CalendariumRomanum::Celebration:0x00000001715790 @title="Saint John Eudes, priest", @rank=#<struct CalendariumRomanum::Rank priority=3.12, desc="Optional memorials", short_desc="optional memorial">, @colour=:white>]
```

Unless a sanctorale is loaded, `Calendar` only counts with
temporale feasts, Sundays and ferials.
