## Unreleased

## [0.2.0] - 2022-02-08

# Added

* Added iOS implementation of method `stopPositioning` that can be used to stop positioning. This method also stops navigation if it was started.
* Added a new parameter `useRemoteConfig` in `LibrarySettings` to enable the [Remote Configuration](https://situm.com/docs/07-remote-configuration/) when positioning. This parameter only works in Android right now.

# Changed
* Changed `captureTouchEvents` behaviour in iOS to be equal to Android behaviour as described in Version 0.0.9. 

