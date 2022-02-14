## Unreleased

### Added
* New method `stopNavigation` to stop navigation if it was started. Working in Android.
* New methods for watching the navigation process (also working in Android right now):
  * `onNavigationRequested` to get notified when the navigation was requested.
  * `onNavigationError` to get notified in the case that an error was produced during navigation.
  * `onNavigationFinished` to get notified when the navigation finishes.

### Changed
* Renamed `BuildingLocation` exported interface to `Point`.