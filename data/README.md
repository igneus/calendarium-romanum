# Calendar data

Sanctorale calendar data are defined in plain-text files following
the format specified below.

Some sample data files may be found in this directory.

## Data format

### Comments, meaningless whitespace

Anything following a `#` is considered comment and thus ignored.

Empty lines are ignored.

### Month headings

Line beginning with a `=` is a month heading and may only contain
a number from range 1-12.

### Calendar entries

A calendar entry is a line of this format:

```
[MONTH/]DAY [RANK] [COLOUR] : TITLE
```

If the calendar entry is preceded by a month heading, MONTH is
optional.

DAY must be a number valid as a possible date in the given month.
(29 is valid in February, as it sometimes occurs;
31 is not valid in April, as there is never April 31st.)

RANK is a single letter m=memorial, f=feast, s=solemnity.
If omitted, optional memorial is default.
The letter can be followed by a number, e.g. ```f2.5``` - the number
must be valid celebration rank priority as defined in
[lib/calendarium-romanum/enums.rb](../lib/calendarium-romanum/enums.rb)

COLOUR is a single letter R=red, W=white (G=green, V=violet normally
shouldn't be necessary in a sanctorale calendar, but both are available
for exceptional cases).
If not specified, white is default.

TITLE is a simple text - title of the celebration - without formatting.

There may be several entries for a day (optional memorials).

## Check your data

Included is a script controlling correctness of data files
and printing detected errors

```
$ ruby bin/calendariumrom.rb errors path/to/my/datafile.txt
```

## How to use the Czech calendars

The files named `czech-*.txt`, when layered properly,
can be used to assemble
proper calendar of any diocese in the Czech Republic.
They were made for the author's practical purposes, but also
as an example of organization of structured calendar data.
Data for any other country could be prepared similarly.

There are three layers:

1. country
2. ecclesiastical province
3. diocese

The tree of correct combinations looks like this:

* `czech-cs.txt`
  * `czech-cechy-cs.txt`
    * `czech-praha-cs.txt`
    * `czech-hradec-cs.txt`
    * `czech-litomerice-cs.txt`
    * `czech-budejovice-cs.txt`
    * `czech-plzen-cs.txt`
  * `czech-morava-cs.txt`
    * `czech-olomouc-cs.txt`
    * `czech-brno-cs.txt`
    * `czech-ostrava-cs.txt`
