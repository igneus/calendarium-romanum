# Changelog

## [0.0.2] 2016-08-27

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
