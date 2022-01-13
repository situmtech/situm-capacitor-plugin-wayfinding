## Unreleased

### Added

* Added methods `selectPoi(...)` and `selectBuilding(...)` to select a POI or a Building in the map.
* Added methods `navigateToPoi(...)` and `navigateToLocation(...)` to request navigation to a POI or a location.

### Changed

* Updated WYF version to 0.9.1(https://situm.com/docs/01-android-wyf-changelog/#0-toc-title), which compiles and targets Android API 31. Now your app must also target Android API 31 or above. Projects behind API 31 must:
  * Change `targetSdkVersion` and `compileSdkVersion` in `build.gradle` and/or `variables.gradle`.
  * Make sure the Gradle JDK points to version 11 (for example, Android Studio embedded JDK).
  * Update the main activity in `AndroidManifest.xml` to explicitly declare `android:exported="true"`.
