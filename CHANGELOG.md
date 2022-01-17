# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [0.0.8] - 2022-01-17

### Added

* Added methods `selectPoi(...)` and `selectBuilding(...)` to select a POI or a Building in the map.
* Added methods `navigateToPoi(...)` and `navigateToLocation(...)` to request navigation to a POI or a location.

### Changed

* Updated WYF version to 0.9.1(https://situm.com/docs/01-android-wyf-changelog/#0-toc-title), which compiles and targets Android API 31. Now your app must also target Android API 31 or above. Projects behind API 31 must:
  * Change `targetSdkVersion` and `compileSdkVersion` in `build.gradle` and/or `variables.gradle`.
  * Make sure the Gradle JDK points to version 11 in your project configuration (recommended Android Studio embedded JDK).
  * Update the main activity in `AndroidManifest.xml` to explicitly declare `android:exported="true"`.
* Fixed a bug that prevents load errors to be notified. Now all the errors produced on calls to SitumWayfinding.load() are notified. A message containing useful information is returned in all cases.

## [0.0.7] - 2021-12-30

### Added

* Added `onPoiSelected`, `onPoiDeselected` and `onFloorChange` methods for listening POIs and floors events.
* Android implementation is available now for both POIs and floors events.
* Added `setCaptureTouchEvents` method to disable/enable the capture of UI events inside the map box. Working only in Android right now.

### Fixed
* `userPositionIcon` and `userPositionArrowIcon` routes are now also valid for iOS.

## [0.0.6] - 2021-12-28

### Added 
* Implementation in iOS of fields `searchViewPlaceholder`, `useDashboardTheme`, `userPositionIcon` and `userPositionArrowIcon` in `LibrarySettings`

### Changed
* Updated iOS WYF native dependency to version to 0.1.18

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
