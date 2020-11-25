# Changelog

## [0.8.0] 2020-11-25

### Fixed

- several fixes to the solemnity transfer rules:
  - the algorithm was searching for free days only forwards,
	but liturgical law assumes closest free day, even earlier
  - check that two solemnities are not transferred to the same date,
    overwriting one another
  - the special rule on Annunciation from *Normae universales* 60
	implemented
- fixed bug in computation of the date of Baptism of the Lord if Epiphany
  is transferred to Sunday
- fixed bug in `Sanctorale#update` preventing more than one `Celebration`
  with nil `#symbol` in a single `Sanctorale`
- `CelebrationFactory` was setting `Celebration#date` (if not specified)
  to false instead of expected nil (thus breaking type promises)
- data: `czech-cs.txt`: typo fixed in the feast *symbol* of St. Bartholomew;
  spelling of several feast titles corrected
- data: `czech-cs.txt`: proof-read against official sources, feasts
  of "BVM, Queen of Angels" and St. Teresa of Calcutta deleted
  (they are not on the calendar of Czech and Moravian dioceses,
  incorrect information was copied from Czech Wikipedia at the time
  of the data file's creation)
- data: all: Dedication of the Lateran Basilica is feast of the Lord
  (had incorrect rank of a normal feast so far)
- data: `universal-en.txt`: several inaccuracies concerning liturgical
  colour fixed

### Added

- `liturgical_law/`: all documents of liturgical legislation
  containing the liturgical calendar rules (original Latin text)
  in Markdown format, with Ruby code examples proving that
  the rules are implemented correctly;
  the code examples are all executed as part of the gem's test suite
- `SanctoraleWriter` (contributed by Mike Kasberg @mkasberg)
- `PerpetualCalendar.new` accepts keyword argument `vespers`
  (cf. `Calendar.new` argument of the same name)
- `Rank#optional_memorial?`, `#obligatory_memorial?`
- `AbstractDate#in_year` - more readable alias of `#concretize`
- `Rank#succ` - (among other things) allows constructing `Range` of `Rank`s
- `Calendar#transferred`
- `Temporale::Extensions::DedicationBeforeAllSaints` defining the solemnity
  of Aniversary of Dedication for churches celebrating it on the movable
  date on the last October Sunday
- `Temporale::Extensions.all` - method listing all Temporale extensions
  defined by the gem
- `Temporale#each_day`
- `Temporale::EasterTable` - class handling a simple plaintext format
  for tables of Easter dates
- `Celebration.new`: new argument `sunday`
- `SanctoraleLoader`: proper solemnities/feasts/memorials
  can be specified also by adding suffix `p` to the rank code
  (instead of rank priority number used so far),
  similarly suffix `l` can be used to specify proper rank for
  feasts of the Lord
- data: `universal-1969-la.txt` - historical first version
  of the General Roman Calendar
- module `Constants` containing all the constants from `Colours`,
  `Seasons` and `Ranks`

### Changed

- the gemspec now declares requirement of Ruby >= 2.0
- `Calendar.new` can be called also without the `year` argument if `Temporale`
  is provided (thus calling `Calendar.new(temporale, sanctorale)`
  instead of `Calendar.new(year, sanctorale, temporale)`)
- Easter Triduum is now dealt with as a separate `Season`,
  because *Normae universales* 18-21 clearly set the Triduum apart from
  both Lent and Eastertide
- `Temporale::Extensions::ChristEternalPriest` specifies celebration
  symbol (so far it was nil)
- `Celebration.new` supports keyword arguments (as an alternative to
  or even in combination with the positional ones)
- `Temporale`: business logic guaranteeing that `Celebration#sunday?`
  is true also for privileged Sundays (Advent, Lent)
- `calendariumrom` executable: all subcommands dealing with sanctorale
  data files accept special file name `-` and load sanctorale data
  from stdin in that case
- `Enum`, `Colours`, `Seasons`, `Ranks` and `Data` changed from classes
  to modules

### Acknowledgements

Improvements not affecting the gem's public interface (and thus not listed
in the changelog) contributed by

- Ihor Voloshyn @Snick555
- Dmitry Zhmurko @zhmurko

## [0.7.1] 2020-06-28

### Fixed

- `SanctoraleFactory.load_with_parents` crashing on files without
  metadata
- `Sanctorale#update` prohibiting application of a particular
  calendar which moves s celebration contained in the calendar being
  updated to an earlier date
  (as exemplified by the bundled calendar of diocese of Litoměřice,
  Czech Republic: on calendarium-romanum 0.7.0
  `CalendariumRomanum::Data['czech-litomerice-cs'].load_with_parents`
  raises `ArgumentError` complaining about non-unique celebration symbols)
- broken links in YARD documentation (due to files missing in the
  gem archive and basename clashes)

### Changed

- if `Sanctorale#update` raises `ArgumentError` complaining about
  non-unique celebration symbols, the updated `Sanctorale` instance
  is left in an inconsistent internal state (more than one occurrence
  of at least one celebration symbol)
- some additional non-code files (mostly for YARD documentation)
  included in the gem archive

## [0.7.0] 2020-06-21

### Fixed

- St. Sebastian was missing in the French version of General Roman Calendar
- St. of Pietrelcina had incorrect rank in the Czech calendar
- `Sanctorale#add`: invalid attempt (i.e. an attempt raising an exception)
  to add a second (or n-th) celebration for a given date was causing
  inconsistency in the instance's internal state
- CLI: `calendariumrom query` wasn't printing celebrations of the highest
  ranks (spotted and fixed by Mike Kasberg @mkasberg)
- CLI: got rid of a deprecation warning of the `i18n` gem
  concerning `I18n.enforce_available_locales` (by Mike Kasberg @mkasberg)

### Added

- data: General Roman Calendar in Spanish + Spanish locale (by Alejandro Ulate @CodingAleCR)
- data: optional memorials of St. Paul VI, Our Lady of Loreto, St. Faustina Kowalska
- data: diocese of Prague: optional memorial of Bl. Friedrich Bachstein and companions
- `Day#weekday_name` (by Ronald Walker @RonWalker22)
- `Day#to_s`, `Celebration#to_s` (by PJ Pollina @pjpollina)
- all sanctorale data files are provided with celebration symbols (available as
  `Celebration#symbol` when loaded)
- `SanctoraleLoader` loads the YAML front matter (if provided),
  to `Sanctorale#metadata` (new property added for this purpose)
- `SanctoraleFactory` methods merge not only sanctorale contents,
  but also metadata
- `SanctoraleFactory.load_with_parents`, `Data#load_with_parents`
  to conveniently load sanctorale file hierarchies based on their
  metadata (using key `"extends"`)
- `calendarium-romanum/cr` defining `::CR` shortcut constant
- huge improvement of the API documentation

### Changed

- data files format: celebration symbols never more start with a colon
- `Sanctorale#add` throws `ArgumentError` on attempt to add a `Celebration`
  with `#symbol` which is already present in the given sanctorale
- all `#each` and `#each_*` methods defined in the gem return `Enumerator`
  if called without a block

## [0.6.0] 2018-03-27

### Fixed

*Feature release - bugs were only introduced, not fixed :)*

### Added

- now handled: *Saturday Memorial of the Blessed Virgin Mary*
- new memorial of *Mary, Mother of the Church*
  (both handled by `Temporale`)
- `Temporale#==`, `Sanctorale#==`
- `Calendar#populates_vespers?` (access value of an option)
- `Temporale#[]`, `Sanctorale#[]`, `PerpetualCalendar#[]`
- `Celebration#date` - only set for fixed-date celebrations,
  contains the celebration's *usual* date (as `AbstractDate` instance),
  thus making it possible
  to check if a solemnity was transferred and what would be
  it's normal date if the transfer didn't occur
- `Celebration#cycle` - returns either `:temporale` or `:sanctorale`
- cycle predicates:
  `Celebration#temporale?` and `#sanctorale?`
- `Calendar#each` - yields each day of the liturgical year
- missing rank predicates:
  `Rank#ferial?`, `Rank#sunday?`,
  `Celebration#ferial?`, `Celebration#sunday?`
- `Celebration#symbol` can be specified also in sanctorale data files
  (but data files with symbols are not yet available)
- CLI: `calendariumrom version` prints gem version

### Changed

- `Calendar#==` used to compare only class and year, now it compares
  complete internal data
- `Colour#to_s` and `Season#to_s` now return meaningful values
  like `"#<CalendariumRomanum::Colour red>"`
  and `"#<CalendariumRomanum::Season lent>"`;
  return value of `Rank#to_s` changed to match the common format
- English temporale feast names edited to match the standard US
  liturgical books (by Mike Kasberg @mkasberg)
- `examples/` directory removed (README is now the main source
  of copy-pastable examples)
- file naming unified: `calendarium-romanum/sanctoraleloader.rb`
  renamed to `.../sanctorale_loader.rb`

## [0.5.0] 2017-11-01

### Fixed

- transfer of Epiphany to a Sunday was breaking numbering of weeks
  of the Ordinary Time
- `Day.new()` (call without any arguments) was crashing
- shebang of `calendariumrom`
- CLI: `calendariumrom query` was printing internal representation
  of a `Season` object instead of human-readable season name
  (spotted and fixed by Simon Szutkowski @simonszu)
- MRI 2.x interpreter warnings

### Added

- first Vespers of Sundays and solemnities: optional feature
  of the `Calendar` (constructor has new keyword argument
  `vespers: true` to activate it), populates `Day#vespers`
  with a `Celebration` if Vespers should be taken from the following
  day
- proper handling of collision between *Immaculate heart of Mary*
  and another obligatory memorial ([CDW Prot. n. 2671/98/L](http://www.vatican.va/roman_curia/congregations/ccdds/documents/rc_con_ccdds_doc_20000630_memoria-immaculati-cordis-mariae-virginis_lt.html))
- `Calendar#[]` - alias of `Calendar#day`, but with additional
  support for a `Range` of `Date`s (returns an `Array` of `Dates`
  when called this way;
  by Brian Gates @bgates)
- `Celebration#change(title: nil, rank: nil, colour: nil, color: nil, symbol: nil)` -
  returns a copy of the celebration with values of selected
  properties replaced by those passed as arguments
- `Celebration#symbol` - machine-readable unique identifier
  of a celebration, for now only for solemnities of the temporale
- CLI: `calendariumrom query` supports printing a day, month or year
  (by Simon Szutkowski @simonszu)
- CLI: `calendariumrom query` supports apart of bundled calendars
  also custom ones, specified on the command line
  (by Simon Szutkowski @simonszu)
- CLI: `calendariumrom cmp` correctly handles celebrations
  present in only one of the compared sources
- data: memorials of saint popes John XXIII and John Paul II added
  to Universal Roman calendar in Latin and to the calendar
  of Czech and Moravian dioceses where they were missing

### Changed

- ferials of the final week of Advent have proper titles
- ordinals in French names of Sundays and ferials have proper
  suffixes
- `Day.new` signature changed from argument Hash
  to Ruby 2 keyword arguments (no change in argument names
  or count, but previously it wouldn't even notice unexpected
  arguments, now it will crash when encountering them)
- `SanctoraleLoader` raises always `InvalidDataError`
  (it used to raise `RangeError` on invalid date and
  `RuntimeError` on other kinds of invalid data)
- `CelebrationFactory` creates also temporale solemnities
  (useful mostly in specs)
- CLI: `calendariumrom errors` fails gracefully, without backtrace

## [0.4.0] 2017-09-02

### Fixed

- `Sanctorale#replace` saving the supplied array as part of
  the internal data structures (and thus allowing their -
  usually unintentional - modification by external code)
- `Calendar` unintentionally modifying `Sanctorale` internal data
  when handling optional memorials
- errors in English ordinals greater than 10 ("21th" -> "21st" etc.)
- `Ranks::FERIAL.memorial?` wrongly returning `true`
- rank of *All Souls* fixed in all data files

### Added

- support for transfer of Epiphany, Ascension and Corpus Christi
  to a Sunday (GNLYC 7)
- General Roman Calendar in French and French localization
  (by Azarias Boutin @AzariasB)
- `PerpetualCalendar`
- `Season#name`, `Colour#name` - localized human-readable names

### Changed

- interface for `Temporale` extensions changed completely:
  extensions are self-contained, isolated; their sole responsibility
  is to yield data
- `Calendar` stripped of the ability to create new instances
  with the same settings:
  - `Calendar#pred` and `#succ` removed
  - `Calendar.new` receives `Temporale` *instance*
    (instead of a temporale factory)
- `Calendar#day` raises `RangeError` if the day is earlier than
  1st January 1970 (day of introduction of the implemented calendar
  system)
- `Temporale::Dates.easter_sunday` doesn't return Julian calendar
  Easter date for years <= 1752 (this library isn't intended to be used
  for years earlier than 1970)
- `Day#==` and `Calendar#==` test object contents, not identity
- `Temporale::Dates.body_blood` renamed to `.corpus_christi`
- `Sanctorale#freeze` freezes also the internal data structures
- `Calendar#freeze` freezes contained `Temporale` and `Sanctorale`
- seasons and colours indexed by their symbols, not by index number -
  e.g. `Seasons[:lent]`, `Colours[:violet]`
- `Calendar#celebrations_for` made private

## [0.3.0] 2017-08-07

### Fixed

*This is a feature release - bugs were only introduced, not fixed :)*

### Added

- `Celebration#title` is now being generated for all Sundays and
  ferials (was empty)
- ferials of the Holy Week and of the last week of Advent
  have proper ranks
- new rank `Ranks::COMMEMORATION` introduced;
  during privileged seasons, suppressed memorials, which
  can be commemorated in the Divine Office (see GILH 239),
  appear in `Day#celebrations` with this rank
- memorial of the *Immaculate Heart of Mary*
  (although it really belongs to the sanctorale, as a movable feast
  it is implemented in `Temporale`)
- support for extending `Temporale` with additional feasts
  (`Temporale.with_extensions`, `Temporale.add_celebration`,
  additional optional argument accepted by `Calendar.new` and
  `Calendar.for_date`)
- `Temporale::Extensions::ChristEternalPriest` - `Temporale` extension
  implementing the feast of *Christ the Eternal Priest*,
  celebrated in some dioceses and religious institutes
  on Thursday after Pentecost
- `Temporale::Dates` - module containing all the
  temporale-solemnity-date-computing algorithms used in `Temporale`
- `Temporale#year`
- sanctorale data files may have YAML front matter
  (a YAML document with metadata placed before the main content)

### Changed

- seasons and colours are represented by `Season` and `Colour`
  instances, not by `Symbol`s
- `Temporale#advent_sunday` and most `#*_advent_sunday`
  removed, only `Temporale#first_advent_sunday` remains
- `Temporale#weekday_before`, `#weekday_after`, `#octave_of`,
  `#monday_before` etc., `#monday_after` etc. removed
  (all these general date helpers now reside in `Temporale::Dates`)
- unused attribute `Day#vespers` removed
- `Temporale#concretize_abstract_date` removed

## [0.2.1] 2017-07-21

### Fixed

- `AbstractDate` validity checks refusing 29th February

## [0.2.0] 2017-07-20

### Fixed

- numbering of Ordinary Time Sundays after Pentecost
- `Calendar#day` when an instance of `DateTime` is supplied as argument
- minor fixes in data files
- `calendariumrom` executable (broken in recent releases)

### Added

- missing *temporale* feast days: Ash Wednesday, Palm Sunday, Ascension,
- new bundled locales: Latin, Italian, Czech
- contents of `Seasons`, `Ranks` and `Colours` can be explored via `each` and `all`
- bundled data files easily accessible through `CalendariumRomanum::Data`

### Changed

- `Rank` never more inherits from `Struct`
- `Seasons`, `Ranks` and `Colours` changed from modules to classes
- `Sanctorale` raises `ArgumentError` on attempt to load two celebrations of rank other than optional memorial on a single day
- data file format: rank letter is optional when the rank is specified by number
- data file format: rank and colour letters are treated case-insensitively

## [0.1.0] 2017-02-25

### Fixed
- computing date of Holy Family when there is no Sunday between December 25th and January 1st (by Eddy Mulyono @eddymul)
- missing information for some celebrations added to the General Roman Calendar in English (by Andrea Ferrato @ferra-andre)

### Added
- General Roman Calendar in Italian (by Andrea Ferrato @ferra-andre)
- `CalendariumRomanum::SanctoraleFactory` for loading of layered sanctorale calendars
- `Rank#short_desc` value for unprivileged Sunday and privileged ferial
- Temporale feast titles and some other strings can be translated (gem `i18n` used)

### Changed
- [breaking change] `SanctoraleLoader#load` argument order changed

## [0.0.3] 2016-08-27

### Fixed
- fatal constant reference bug in `Temporale`
- the specs that covered it

## [0.0.2] 2016-08-27 YANKED

release yanked, as it contained a fatal bug in `Temporale`,
resulting in `NameError` being raised on each initialization

### Fixed
- all celebrations handled by `Temporale` purged from the sanctorale
  data files. Note that having temporale *solemnities* in sanctorale
  data results in these being duplicated due to the transfer of
  impeded solemnities.
- rank of Mary Magdalene updated in the sanctorale data files
- rank of the feast of the Holy Family fixed

### Changed
- solemnity of Mary, Mother of God (January 1st) is handled by
  `Temporale`

## [0.0.1] 2016-08-20

### Added
- transfer of impeded solemnities

### Changed
- sanctorale data must be loaded before `Calendar` initialization
- `Calendar#sanctorale` is read-only
- dropped `Calendar.day`, `Sanctorale#validate_date`
- `SanctoraleLoader` raises exceptions on errors (instead of writing invalid entries to a log and skipping them)
