## Unreleased

### Changed

* Updated WYF Android dependency to version 0.15.2.
* The user is now centered in the map after requesting navigation indications.
* Modified the default navigation parameters:
  * [Indications interval](https://developers.situm.com/sdk_documentation/android/javadoc/latest/es/situm/sdk/navigation/navigationrequest.builder#indicationsInterval(long)) changed from 10s to 30s.
  * [Distance to change indication](https://developers.situm.com/sdk_documentation/android/javadoc/latest/es/situm/sdk/navigation/navigationrequest.builder#distanceToChangeIndicationThreshold(double)) moved from 0m to 15m.
  * Flag to [ignore low quality locations](https://developers.situm.com/sdk_documentation/android/javadoc/latest/es/situm/sdk/navigation/navigationrequest.builder#ignoreLowQualityLocations(boolean)) now defaults to false.
