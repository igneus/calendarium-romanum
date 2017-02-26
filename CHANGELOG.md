# Changelog

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
