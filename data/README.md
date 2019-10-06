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
[MONTH/]DAY [RANK] [COLOUR] [IDENTIFIER] : TITLE
```

If the calendar entry is preceded by a month heading, MONTH is
optional.

DAY must be a number valid as a possible date in the given month.
(29 is valid in February, as it sometimes occurs;
31 is not valid in April, as there is never April 31st.)

RANK is a single letter m=memorial, f=feast, s=solemnity.
If omitted, optional memorial is assumed.

When it is desirable to specify rank of a celebration
with greater precision, e.g. in order to distinguish feasts
inscribed in the General Roman Calendar from proper feasts,
use rank number instead of a rank letter.
Rank priority numbers are defined in
[lib/calendarium-romanum/enums.rb](../lib/calendarium-romanum/enums.rb)
and correspond to section and subsection numbers in
the Table of Liturgical Days
(see end of the [General Norms](https://www.ewtn.com/library/CURIA/CDWLITYR.HTM)).
This is why the sequence is non-continuous:
`1.4` is followed by `2.5` and `2.9` by `3.10`.

The example below presents pairs of equivalent lines,
the first one specifying rank by letter, the second one by number.
Rank letters are always interpreted as if the celebration
was inscribed in the General Roman Calendar.

```
3/19 s : Saint Joseph Husband of the Blessed Virgin Mary
3/19 1.3 : Saint Joseph Husband of the Blessed Virgin Mary

1/25 f : The Conversion of Saint Paul, apostle
1/25 2.7 : The Conversion of Saint Paul, apostle

1/26 m : Saints Timothy and Titus, bishops
1/26 3.10 : Saints Timothy and Titus, bishops

1/27 : Saint Angela Merici, virgin
1/27 3.12 : Saint Angela Merici, virgin
```

As an example of a proper celebration (which requires rank number
when exact ranking is important) let's use solemnity of the
principal patron of Bohemia, martyr duke St. Wenceslas:

```
9/28 1.4 R : Sv. Václava, mučedníka, hlavního patrona českého národa
```

When you have dificulties remembering meanings of the numbers,
but are comfortable with rank letters, it might be helpful for you
to use rank numbers *alongside* the letters.
This is supported too, you will find this format used throughout
the bundled data files.

```
9/28 s1.4 R : Sv. Václava, mučedníka, hlavního patrona českého národa
```

COLOUR is a single letter R=red, W=white (G=green, V=violet normally
shouldn't be necessary in a sanctorale calendar, but both are available
for exceptional cases).
If not specified, white is default.

TITLE is a simple text - title of the celebration - without formatting.

IDENTIFIER is a single "word" consisting of lowercase letters and
underscores, at least 2 characters long.
It is optional and serves as a unique machine-readable identifier
of the given celebration.

There may be several entries for a day (optional memorials).

### YAML metadata

At the beginning of the file there may be a "YAML front matter"
(cf. [use of YFM in Jekyll][yfm]) -
a YAML document with arbitrary metadata.

Currently the front matter is ignored  when loading sanctorale
data files, but there are plans to make it available
to application code.

## Check your data

Included is a script controlling correctness of data files
and printing detected errors

```
$ calendariumrom errors path/to/my/datafile.txt
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

`SanctoraleFactory` is a helper class making it really easy
to build `Sanctorale` from multiple layers:

```ruby
CR = CalendariumRomanum
layers = %w(czech-cs czech-cechy-cs czech-praha-cs).collect do |id|
  CR::Data[id].load
end

layered_sanctorale = CR::SanctoraleFactory.create_layered(*layers)
```

[yfm]: https://jekyllrb.com/docs/front-matter/
