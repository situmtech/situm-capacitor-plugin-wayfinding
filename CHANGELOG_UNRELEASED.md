## Unreleased

### Added
* Added a new parameter `useRemoteConfig` in `LibrarySettings` to enable the [Remote Configuration](https://situm.com/docs/07-remote-configuration/) when positioning. This parameter only works in Android right now.
* New method `stopNavigation` to stop navigation if it was started. Working in Android.
* New methods for watching the navigation process (also working in Android right now):
  * `onNavigationRequested` to get notified when the navigation was requested.
  * `onNavigationError` to get notified in the case that an error was produced during navigation.
  * `onNavigationFinished` to get notified when the navigation finishes.

### Changed
* Renamed `BuildingLocation` exported interface to `Point`.
