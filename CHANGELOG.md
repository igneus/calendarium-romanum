# Changelog

## [0.0.1] 2016-08-20

### Added
- transfer of impeded solemnities

### Changed
- sanctorale data must be loaded before `Calendar` initialization
- `Calendar#sanctorale` is read-only
- dropped `Calendar.day`, `Sanctorale#validate_date`
- `SanctoraleLoader` raises exceptions on errors (instead of writing invalid entries to a log and skipping them)
