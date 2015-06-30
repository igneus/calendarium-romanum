# Calendar data

Sanctorale calendar data are defined in plain-text files following
conventions specified below.

Here are some sample data files, right now not as thoroughly proof-read
as it would be desirable. Corrections are welcome

## Data format

Anything following a ```#``` is ignored.

Empty lines are ignored.

Line beginning with a ```=``` is a month heading and may only contain
a number from range 1-12.

A calendar entry is a line with this format:

```
DAY <RANK> <COLOUR> : TITLE
```

DAY must be a number valid as a possible date in the given month.
(29 is valid in February, as it sometimes occurs;
31 is not valid in April, as there is never April 31st.)

RANK is a single letter m=memorial, f=feast, s=solemnity.
If omitted, optional memorial is default.
The letter can be followed by a number, e.g. ```f2.5``` - the number
must be valid celebration rank priority as defined in
[lib/calendarium-romanum/enums.rb](../lib/calendarium-romanum/enums.rb)

COLOUR is a single letter R=red, W=white, G=green, V=violet.
If not specified, white is default.
Normally you should only need to specify red.

TITLE is a simple text - title of the celebration - without formatting.

There may be several entries for a day (optional memorials).

## Check your data

Included is a script controlling correctness of data files
and printing detected errors

```
$ ruby bin/calendariumrom.rb errors path/to/my/datafile.txt
```

## How to use the Czech calendars

Because of being the author's home, Czech Republic is currently
best covered by proper calendars.
These are designed for loading in three layers:
1. common calendar of the Czech Republic
2. province calendar (Czech/Moravian)
3. diocese calendar
