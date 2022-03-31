### Changed
* Updated iOS WYF native dependency to version to 0.4.0
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
* Updated native Wayfinding Android to version 0.15.1.