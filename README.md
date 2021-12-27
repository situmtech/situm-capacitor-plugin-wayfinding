# situm-capacitor-plugin-wayfinding

Situm Wayfinding Plugin for Capacitor has been designed to create indoor location applications in the simplest way. It has been built in the top of the Situm SDK.

## Configuration

First of all, you must configure your Capacitor project. This has been already done for you in [the sample application](https://github.com/situmtech/situm-capacitor-plugin-wayfinding-getting-started), but nonetheless you can read the official [Capacitor documentation](https://capacitorjs.com/docs/getting-started).

Dont forget to add the platforms of your choice:
```bash
your/project/path$ npx cap add <platform>
```
Remember that this module implements the Android and iOS native interfaces but not the web interface as it is intended for use in mobile applications.

To install `situm-capacitor-plugin-wayfinding`, add the next line to your `package.json` file:
```json
"dependencies": {
    "situm-capacitor-plugin-wayfinding": "latest"
```

Then run `npm install` and `npx cap sync` to install packages, copy the web app build and Capacitor configuration file into the native platform project and update the native plugins and dependencies previously referenced:
```bash
your/project/path$ npm install && npx cap sync
```

In your project, add the HTMLElement that will hold the Situm Wayfinding Module:
```html
<div id="situm-map"></div>
```

The size of this `div` will be the size of the native module. That size must be greater than 0.
Note that right now it is not possible to modify the size or position of the native element, which affects both scrollable elements and screen rotations.

The native map will be drawn behind your HTML. Make sure the background of the parent HTML elements is transparent. For example, in ionic:
```css
ion-content {
    --background: none;
}
```

And finally in your Typescript layer, initialize the module:
```typescript
const librarySettings = {
    user: "YOUR_SITUM_USER",
    apiKey: "YOUR_SITUM_APIKEY",
    iosGoogleMapsApiKey: "YOUR_IOS_GOOGLE_MAPS_APIKEY",
    buildingId: "YOUR_BUILDING_ID",
    dashboardUrl: "https://dashboard.situm.com",
    hasSearchView: true,
    searchViewPlaceholder: "Capacitor WYF",
    useDashboardTheme: false,
};
await SitumWayfinding.load(element, librarySettings);
```

## Requirements:

### Setup your Situm Account

You must set up an account in our [Dashboard](https://dashboard.situm.com), retrieve your API KEY and configure your first building:

1. Go to the [sign in form](http://dashboard.situm.com/accounts/register) and enter your username and password to sign in.
2. Go to the [account section](https://dashboard.situm.com/accounts/profile) and on the bottom, click on “generate one” to generate your API KEY.
3. Go to the [buildings section](http://dashboard.situm.com/buildings) and create your first building.
4. Download Situm Mapping Tool in Play Store (Only Android devices) and calibrate your building. Check out our user guide for detailed information.

### Google Maps API KEY:

A Google Maps API KEY is required for this plugin to work. 
More info is available in the official [Google Documentation](https://developers.google.com/maps/documentation/android-sdk/get-api-key).
Make sure to enable your API KEY for the platforms of your choice.

1. iOS: put your API KEY in the `LibrarySettings` object of this example app.
```typescript
const librarySettings = {
          ...
          iosGoogleMapsApiKey: "YOUR_IOS_GOOGLE_MAPS_APIKEY",
          ...
        };
```
2. Android: the Google Maps API KEY must be set in the `AndroidManifest.xml` file (that you will find in the `android/src/main` folder) of your project.
```xml
<meta-data android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ANDROID_GOOGLE_MAPS_APIKEY"/>
```

### Dependencies:

At this moment this module uses [Capacitor Google Maps](https://github.com/situmtech/capacitor-google-maps). Add this dependency to your `package.json` to let Capacitor add the corresponding native project modules:
```json
"dependencies": {
    "@capacitor-community/capacitor-googlemaps-native": "git+https://github.com/situmtech/capacitor-google-maps.git#situm-alpha.0"
```

#### Android

This module depends on the [Situm Wayfinding for Android visual component](https://situm.com/docs/01-android-quickstart-guide/). You must add the Situm Repository to your project level `build.gradle` file (again, in the `android` folder of your project):
```groovy
allprojects {
    repositories {
        maven { url "https://repo.situm.com/artifactory/libs-release-local" }
        ...
```

The location permission is required in your app level `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

If you are targeting Android Pie devices (or above), add Apache Http Legacy to your `AndroidManifest.xml`:
```xml
<uses-library
  android:name="org.apache.http.legacy"
  android:required="false"/>
```

## Customization:

### Colors

Use the parameter `useDashboardTheme` of `LibrarySettings` to decorate the whole WYF UI with your organization theme.

### Positioning icons

Use the fields `userPositionIcon` and `userPositionArrowIcon` in `LibrarySettings` to set the icons representing the user position (without and with orientation respectively).

The path is relative to the native __android assets folder__ and __iOS App folder__. It was inspired in the results of [`npx cap sync`](https://capacitorjs.com/docs/cli/sync) as you will see bellow. For example, for the following tree:
```
android/app/src/main/assets/public/
...
├── images
│   ├── arrow_icon.png
│   └── dot_icon.png
...

ios/App/App/public/
...
├── images
│   ├── arrow_icon.png
│   └── dot_icon.png

```

Will apply the following path:
```typescript
  // LibrarySettings:
  const librarySettings = {
    user: "YOUR_SITUM_USER",
    ...
    userPositionIcon: "images/dot_icon.png",
    userPositionArrowIcon: "images/arrow_icon.png"
  };
```

You can manually copy the icons in your native projects, or manage them in the web side.
For the latter, your assets folder will vary depending on the UI framework of your choice, for example:

* Angular: see the [assets property for your build options in the documentation](https://angular.io/guide/workspace-config#additional-build-and-test-options).
* Vue: see the [public folder](https://cli.vuejs.org/guide/html-and-static-assets.html#the-public-folder).

In both cases the execution of `npx cap sync` will copy your assets to a predefined folder, as you can see in the following output:

```
$ npx cap sync
...
✔ Copying web assets from dist to android/app/src/main/assets/public
...
✔ Copying web assets from dist to ios/App/App/public
...
```

Check that folders after executing `npx cap sync` to ensure you are setting the correct path to your icons.

Using or not a UI framework is up to you, the rule is to set a path relative to the native assets folders.

## API

* [`load(...)`](#load)
* [`unload()`](#unload)
* [`setOnPoiSelectedListener()`](#setOnPoiSelectedListener)
* [`setOnFloorChangeListener()`](#setOnFloorChangeListener)
* [Interfaces](#interfaces)


### load(...)

```typescript
load(settings: WayfindingSettings) => Promise<WayfindingResult>
```

| Param          | Type                 |
| -------------- | -------------------- |
| **`settings`** | `WayfindingSettings` |

**Returns:** `Promise<WayfindingResult>`

--------------------


### unload()

```typescript
unload() => any
```

**Returns:** `any`

--------------------

### setOnPoiSelectedListener()

```typescript
setOnPoiSelectedListener((result: OnPoiSelectedResult) { }) => void
```

**Returns:** `void`

--------------------

### setOnFloorChangeListener()

```typescript
setOnFloorChangeListener((result: OnFloorChangeResult) { }) => void
```

**Returns:** `void`

--------------------


### Interfaces


#### WayfindingSettings

| Prop                  | Type  |
| --------------------- | ----- |
| **`mapId`**           | `any` |
| **`librarySettings`** | `LibrarySettings` |
| **`screenInfo`**      | `ScreenInfo` |


#### LibrarySettings

| Prop                         | Type     |
| ---------------------------- | -------- |
| **`user`**                   | `String` |
| **`apiKey`**                 | `String` |
| **`iosGoogleMapsApiKey`**    | `String` |
| **`buildingId`**             | `String` |
| **`dashboardUrl`**           | `String` |
| **`hasSearchView`**          | `Boolean` |
| **`searchViewPlaceholder`**  | `Boolean` |
| **`useDashboardTheme`**      | `Boolean` |
| **`userPositionIcon?`**      | `String` |
| **`userPositionArrowIcon?`** | `String` |


#### ScreenInfo

| Prop                   | Type     |
| ---------------------- | -------- |
| **`devicePixelRatio`** | `Number` |
| **`x`**                | `Number` |
| **`y`**                | `Number` |
| **`width`**            | `Number` |
| **`height`**           | `Number` |


#### WayfindingResult


#### OnPoiSelectedResult

| Prop               | Type     |
| ------------------ | -------- |
| **`key`**          | `String` |
| **`buildingId`**   | `String` |
| **`buildingName`** | `String` |
| **`floorId`**      | `String` |
| **`floorName`**    | `String` |
| **`poiId`**        | `String` |
| **`poiName`**      | `String` |


#### OnFloorChangeResult

| Prop                | Type     |
| ------------------- | -------- |
| **`key`**           | `String` |
| **`buildingId`**    | `String` |
| **`buildingName`**  | `String` |
| **`fromFloorId`**   | `String` |
| **`fromFloorName`** | `String` |
| **`toFloorId`**     | `String` |
| **`toFloorName`**   | `String` |


#### SitumMapOverlays

| Prop           | Type  |
| -------------- | ----- |
| **`overlays`** | `any` |


#### SitumMapOverlay

| Prop         | Type     |
| ------------ | -------- |
| **`x`**      | `Number` |
| **`y`**      | `Number` |
| **`width`**  | `Number` |
| **`height`** | `Number` |
