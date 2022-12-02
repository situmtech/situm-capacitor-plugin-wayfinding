# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.9.3] - 2022-12-02

### Changed
* Updated WYF Android version to 0.21.0. Checkout the [Situm WYF changelog](https://situm.com/docs/01-android-wyf-changelog/#0-toc-title) to see all the features and optimizations added in this new version.

## [0.9.2] - 2022-08-31

### Fixed
* Fixed a bug that hides POIs when `lockCameraToBuilding` is set to true in Android.

## [0.9.1] - 2022-07-08

### Added
* Enabled POI clustering in Android. Now `enablePoiClustering` is working in both iOS and Android.

### Changed
* Updated WYF Android version to 0.16.0.

## [0.9.0] - 2022-07-05
### Added
* Added a new flag `enablePoiClustering` in `LibrarySettings` to activate or deactivate marker clustering of pois displayed in the map. Only in iOS for now, coming soon to Android.
* Updated WYF iOS to version 0.8.0.

## [0.8.0] - 2022-06-23

### Added
* Added a new flag `lockCameraToBuilding` in `LibrarySettings` that locks the map camera to the bounds of the given building.

### Changed
* Updated WYF Android to version 0.15.3.
* Updated WYF iOS to version 0.6.0.

## [0.7.0] - 2022-04-26

### Changed

* Updated WYF Android dependency to version [0.15.2](https://situm.com/docs/01-android-wyf-changelog/#0-toc-title).
* Updated WYF iOS dependency to version to [0.5.0](https://situm.com/docs/02-ios-wyf-changelog/#0-toc-title).

### Added

* Added new option `showSearchBar` to `LibrarySettings` to show or hide the search bar. If it is set to true, the search bar display, if it is set to false, the search bar hidden. By default it is set to true.


## [0.6.0] - 2022-03-31

### Changed

* The plugin dependency `@capacitor-community/capacitor-googlemaps-native` has been changed to `situm-capacitor-googlemaps-native`.
  :warning: You must update the dependency in your project from:
  ```json
    "dependencies": {
        "@capacitor-community/capacitor-googlemaps-native": "git+https://github.com/situmtech/capacitor-google-maps.git#situm-alpha.0",
        ...
  ```
  To:
  ```json
    "dependencies": {
        "situm-capacitor-googlemaps-native": "0.0.3",
        ...
  ```

  __To update to this version follow the steps described below__:

  1. First uninstall the obsolete dependency:
     ```
     $ npm uninstall @capacitor-community/capacitor-googlemaps-native
     ```
  2. Install the new dependency:
     ```
     $ npm install situm-capacitor-googlemaps-native
     ```
  3. Update the plugin:
     ```
     $ npm install situm-capacitor-plugin-wayfinding@latest
     ```
  4. Finally synchronize and run your capacitor project:
     ```
     $ npx cap run
     ```
* Updated iOS WYF native dependency to version to 0.4.0.
* Updated native Wayfinding Android to version 0.15.1.

## [0.5.0] - 2022-03-25

### Added

* Implemented in Android the option `showPoiNames` (in `LibrarySettings`) that displays the name of the POIs on the map above each icon. By default it is set to false. Now it is available for both platforms, iOS and Android.

### Removed

* Removed park labels from Google Maps layer.
* The Situm geofences will not be displayed anymore on the map.

### Changed

* Now the Text-To-Speech button that enables or disables turn by turn spoken indications during navigation is no longer visible.
* Turn by turn spoken indications are now disabled.
* Updated native Wayfinding Android to version 0.15.0.


## [0.4.0] - 2022-03-15

### Added

* Added new option `showPoiNames` to `LibrarySettings` that allows the name of the POIs to be displayed on the map above each POI icon. If it is set to true, the POI name is displayed above the POI icon, if it is set to false, only the POI icon appears. By default it is set to false. :warning: Only in iOS for now, coming soon to Android.

### Changed

* Updated iOS WYF native dependency to version to 0.3.0

## [0.3.1] - 2022-03-04

### Removed
* Removed popups containing information about events and geofences during positioning in Android.

## [0.3.0] - 2022-03-01

### Added

* iOS implentation of parameter `useRemoteConfig` in `LibrarySettings` to enable the [Remote Configuration](https://situm.com/docs/07-remote-configuration/) of location request. 
* iOS implementation of method [stopNavigation](https://github.com/situmtech/situm-capacitor-plugin-wayfinding#stopNavigation) to stop navigation if it was already started.
* iOS implementation of methods for receiving updates of navigation process:
  * [onNavigationRequested](https://github.com/situmtech/situm-capacitor-plugin-wayfinding#onNavigationRequested) to get notified when the navigation was requested.
  * [onNavigationError](https://github.com/situmtech/situm-capacitor-plugin-wayfinding#internalOnNavigationError) to get notified in the case that an error was produced during navigation.
  * [onNavigationFinished](https://github.com/situmtech/situm-capacitor-plugin-wayfinding#internalOnNavigationFinished) to get notified when the navigation finishes.
* iOS implmentation of method [navigateToLocation(...)](https://github.com/situmtech/situm-capacitor-plugin-wayfinding#navigateToLocation) to request navigation to a location.

## [0.2.1] - 2022-02-25

### Fixed
* Fixed improper calls to [`onPoiDeselected`](https://github.com/situmtech/situm-capacitor-plugin-wayfinding#onPoiDeselected) callback.

## [0.2.0] - 2022-02-21

### Added

* Added iOS implementation of method `stopPositioning` that can be used to stop positioning. This method also stops navigation if it was started.
* Added a new parameter `useRemoteConfig` in `LibrarySettings` to enable the [Remote Configuration](https://situm.com/docs/07-remote-configuration/) when positioning. This parameter only works in Android right now.
* New method `stopNavigation` to stop navigation if it was started. Working only in Android.
* New methods for watching the navigation process (also working in Android right now):
  * `onNavigationRequested` to get notified when the navigation was requested.
  * `onNavigationError` to get notified in the case that an error was produced during navigation.
  * `onNavigationFinished` to get notified when the navigation finishes.

### Changed
* Renamed `BuildingLocation` exported interface to `Point`.
* Changed `captureTouchEvents` behaviour in iOS to be equal to Android behaviour as described in Version 0.0.9. 

## [0.1.0] - 2022-02-08

### Added

* Added iOS implementation of method `selectPoi(...)` to select a POI in the map.
* Added iOS implementation of method `navigateToPoi(...)` to request navigation to a POI.

## [0.0.9] - 2022-01-28

### Added

* Added in Android a new method `stopPositioning` that can be used to stop positioning. This method also stops navigation if it was started.
* Added iOS functionality for onPoiSelected, onPoiDeselected and onFloorChange methods for listening POIs and floors events.
* Added iOS functionality to setCaptureTouchEvents method to disable/enable the capture of UI events inside the map box.

### Changed

* Updated iOS WYF native dependency to version to 0.1.19
* Now the method `SitumWayfinding.load(HTMLElement element, ...)` can be called repeatedly.
    * In the first call the native module will be loaded.
    * Successive calls will update the reference to the map div (the given HTMLElement). This is useful in frameworks like Angular that may destroy and recreate the original HTMLElement. In such cases, the HTMLElement reference gets obsolete. As a consecuence, event delegation stops working properly when interacting with HTML elements displayed over the native map. From now on, a call to `load(HTMLElement element, ...)` will make the plugin work as expected.
* Now `captureTouchEvents` is `false` while the map is loading. The default value `true` can now be overwritten in the `load` call using the field `captureTouchEvents` of `LibrarySettings`. The default value will be assigned on `load` success.
* Updated WYF Android version to [0.9.2-alpha](https://situm.com/docs/01-android-wyf-changelog/).

### Fixed
* Fixed async/await internal calls.
* The WYF update (0.9.2-alpha) fixes a missing callback to `onPoiSelected` when `selectPoi(...)` is invoked.

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
