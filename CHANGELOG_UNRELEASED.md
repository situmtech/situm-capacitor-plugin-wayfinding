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
        "situm-capacitor-googlemaps-native": "0.0.1",
        ...
  ```
