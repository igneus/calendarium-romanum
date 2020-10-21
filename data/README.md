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
[MONTH/]DAY [RANK] [COLOUR] [IDENTIFIER] : [TITLE]
```

If the calendar entry is preceded by a month heading, MONTH is
optional.

DAY must be a number valid as a possible date in the given month.
(29 is valid in February, as it sometimes occurs;
31 is not valid in April, as there is never April 31st.)

RANK is a rank code, which can have several forms:

1. *no* rank code - optional memorial will be assumed
1. single letter: `m` = memorial, `f` = feast, `s` = solemnity
1. rank priority number, e.g. `1.3` (defined in
   [lib/calendarium-romanum/enums.rb](../lib/calendarium-romanum/enums.rb),
   and correspond to section and subsection numbers in the Table of Liturgical Days
   in the [General Norms](https://www.ewtn.com/library/CURIA/CDWLITYR.HTM))
1. letter and a priority number, e.g. `s1.3`
1. letter with a specifying suffix, e.g. `sp`: suffix `p` distinguishes
   proper solemnities/feasts/memorials from those inscribed in the General
   Roman Calendar, suffix `l` (only allowed in combination `fl`)
   distinguishes feasts of the Lord from other feasts inscribed
   in the General Roman Calendar.

Single letter codes are used to encode ranks of most celebrations
inscribed in the General Roman Calendar, the other forms for other
ranks (proper celebrations, feasts of the Lord etc.).

The example below presents pairs of equivalent lines,
the first one specifying rank by letter, the second one by number.

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
principal patron of Bohemia, martyr duke St. Wenceslas
(three alternative ways to encode the same rank of a proper solemnity):

```
9/28 1.4 R : Sv. Václava, mučedníka, hlavního patrona českého národa
9/28 s1.4 R : Sv. Václava, mučedníka, hlavního patrona českého národa
9/28 sp R : Sv. Václava, mučedníka, hlavního patrona českého národa
```

Feasts of the Lord similarly require a more specific rank code
than the general `f`:

```
11/9 2.5 lateran_basilica : Dedication of the Lateran basilica
11/9 f2.5 lateran_basilica : Dedication of the Lateran basilica
11/9 fl lateran_basilica : Dedication of the Lateran basilica
```

COLOUR is a single letter R=red, W=white (G=green, V=violet normally
shouldn't be necessary in a sanctorale calendar, but both are available
for exceptional cases).
If not specified, white is default.

IDENTIFIER is a single "word" consisting of lowercase letters and
underscores, at least 2 characters long.
It is optional and serves as a unique machine-readable identifier
of the given celebration.

TITLE is a simple text - title of the celebration - without formatting.
It can be omitted, but only if IDENTIFIER is provided.
Then an internationalization string `"sanctorale.IDENTIFIER"`
is used as celebration title and the title follows `I18n.locale`
the same way as temporale celebration titles do.
(`universal.txt` is an example of data file with no celebration titles
at all, just identifiers.)

There may be several entries for a day (optional memorials).

Entry containing just a date (or just a day if a month heading preceded)
can be used, explicitly declaring that there is no celebration on the
given day. This is occasionally useful to cancel a celebration
inherited from a parent calendar.
For example St. Cyril and Methodius are celebrated on February 14th
by the universal church, but in Czech Republic their feast day is July 5th
and on February 14th there is no other sanctorale celebration.

```
2/14
```

### YAML metadata

At the beginning of the file there may be a "YAML front matter"
(cf. [use of YFM in Jekyll][yfm]) -
a YAML document with arbitrary metadata.
The front matter is parsed when loading the data file
and it's contents are available to the application code
in `Sanctorale#metadata`.

Top-level structure of the document should be a Hash
(or "mapping" in the [YAML specification][yamlspec]'s vocabulary).
It may contain whatever the author finds useful.
A few fields are suggested:

* `title` - name of the calendar in the language of it's contents
  (suitable for the end user)
* `description` - description of the contents in English (suitable for
  people who may not understand the language of the contents,
  e.g. maintainers of multi-language calendar applications)
* `locale` - 2-character code of the content's language
  (may be used by applications to automatically select a matching
  locale for temporale feast names)
* `country` - ISO 3166 alpha2 country code (only for country-specific
  data)
* `province` - name of ecclesiastical province (only for
  province-specific data)
* `diocese` - name of diocese (only for diocese-specific data)
* `extends` - either String or (if multiple parents are needed)
  Array ("sequence" in the [YAML specification][yamlspec]'s vocabulary)
  of more general data file(s) the given file extends
  (usually as relative filesystem paths; can be used by applications
  to automatically load hierarchies of sanctorale data -
  see `SanctoraleFactory.load_with_parents`)

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
[yamlspec]: https://yaml.org/spec/1.2/spec.html
