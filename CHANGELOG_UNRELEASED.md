## Unreleased

# Added
* Added in Android a new method `stopPositioning` that can be used to stop positioning. This method also stops navigation if it was started.
* Added iOS functionality for onPoiSelected, onPoiDeselected and onFloorChange methods for listening POIs and floors events.
* Added iOS functionality to setCaptureTouchEvents method to disable/enable the capture of UI events inside the map box.

# Changed 
* Updated iOS WYF native dependency to version to 0.1.19
* Now the method `SitumWayfinding.load(HTMLElement element, ...)` can be called repeatedly.
    * In the first call the native module will be loaded.
    * Successive calls will update the reference to the map div (the given HTMLElement). This is useful in frameworks like Angular that may destroy and recreate the original HTMLElement. In such cases, the HTMLElement reference gets obsolete. As a consecuence, event delegation stops working properly when interacting with HTML elements displayed over the native map. From now on, a call to `load(HTMLElement element, ...)` will make the plugin work as expected.
* Now `captureTouchEvents` is `false` while the map is loading. The default value `true` can now be overwritten in the `load` call using the field `captureTouchEvents` of `LibrarySettings`. The default value will be assigned on `load` success.
* Updated WYF Android version to [0.9.2-alpha](https://situm.com/docs/01-android-wyf-changelog/).

### Fixed
* Fixed async/await internal calls.
* The WYF update (0.9.2-alpha) fixes a missing callback to `onPoiSelected` when `selectPoi(...)` is invoked.
