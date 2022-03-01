## Unreleased

## [0.3.0] - 2022-02-25

# Added

* iOS implentation of parameter `useRemoteConfig` in `LibrarySettings` to enable the [Remote Configuration](https://situm.com/docs/07-remote-configuration/) of location request. 
* iOS implementation of method [stopNavigation](https://github.com/situmtech/situm-capacitor-plugin-wayfinding#stopNavigation) to stop navigation if it was already started.
* iOS implementation of methods for receiving updates of navigation process:
  * [onNavigationRequested](https://github.com/situmtech/situm-capacitor-plugin-wayfinding#onNavigationRequested) to get notified when the navigation was requested.
  * [onNavigationError](https://github.com/situmtech/situm-capacitor-plugin-wayfinding#internalOnNavigationError) to get notified in the case that an error was produced during navigation.
  * [onNavigationFinished](https://github.com/situmtech/situm-capacitor-plugin-wayfinding#internalOnNavigationFinished) to get notified when the navigation finishes.
* iOS implmentation of method [navigateToLocation(...)](https://github.com/situmtech/situm-capacitor-plugin-wayfinding#navigateToLocation) to request navigation to a location.