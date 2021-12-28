# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.5] - 2021-12-14

### Changed
* Updated iOS WYF native dependency to version to 0.1.17

## [0.0.4] - 2021-11-26

### Added

* Added fields `userPositionIcon` and `userPositionArrowIcon` in `LibrarySettings` to set the icon representing the user position (without and with orientation respectively).

### Fixed

* Now you can add HTML elements over the WYF map and interact with them in iOS (already working in Android).


## [0.0.3] - 2021-11-12

### Added

* Added method `load(settings: WayfindingSettings)` to display a Situm Map in an `HTMLElement`.
* Added method `unload()` to remove the Situm Map from your HTML view.
