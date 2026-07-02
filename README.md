
# Pinpoint Flutter SDK

* [Introduction](#introduction)

* [Features](#features)

* [Getting Started](#getting-started)

    * [Requirements](#requirements)

    * [Supported Platforms](#supported-platforms)

    * [Setup Environment](#setup-environment)

        * [Android](#android)

        * [iOS](#ios)

* [Usage](#usage)

    * [Migration from geolocator](#migration-from-geolocator)

    * [Example](#example)

    * [API](#api)

        * [Geolocation](#geolocation)

            * [Current location](#current-location)

            * [Last known location](#last-known-location)

            * [Listen to location updates](#listen-to-location-updates)

            * [Location settings](#location-settings)

                * [Restrictions of the location settings](#restrictions-of-the-location-settings)

                * [Notes on the location accuracy](#notes-on-the-location-accuracy)

                * [Platform specific location settings (Outdoor positioning only)](#platform-specific-location-settings-outdoor-positioning-only)

            * [Location accuracy for outdoor positions (Android and iOS 14+ only)](#location-accuracy-for-outdoor-positions-android-and-ios-14-only)

            * [Service status updates](#service-status-updates)

      * [Permissions](#permissions)

      * [Location Settings](#location-settings)

      * [Utility methods](#utility-methods)


* [Troubleshooting](#troubleshooting)
  
    * ["I do not get any positions"](#i-do-not-get-any-positions)
  
    * [Android: `Geolocator.checkPermission` always returns `LocationPermission.denied`](#android-geolocatorcheckpermission-always-returns-locationpermissiondenied)

* [License](#license)


## Introduction
The Pinpoint SDK is a cross-platform (Android/iOS) Flutter plugin for [FiRa](https://www.firaconsortium.org) compliant Ultra-Wideband (UWB) positioning with [Pinpoint's](https://pinpoint.de) technology.

This plugin is based on version 14.0.2 of [geolocator](https://pub.dev/packages/geolocator).

## Features

* Indoor Positioning for GNSS/GPS denied areas with Pinpoint's [SATlets](https://www.pinpoint.de/en/products/hardware/satlet)
* Uses Android's [UWB DL-TDOA API](https://developer.android.com/about/versions/17/features#dl-tdoa-api-android-17) and iOS' [Nearby Interaction DL-TDOA API](https://developer.apple.com/documentation/nearbyinteraction/dl-tdoa-ranging)
* Accuracy of up to 30 cm
* Simple Integration


## Getting started
Refer to the example app for an easy integration of the Pinpoint Flutter SDK.
1. Add your credentials for the Pinpoint SDK repository ([Android](#android), [iOS](#ios)).
2. Create a file name `api_key.txt` in `example/assets` and copy your license key to it.
3. Run the app with `flutter run`.

### Supported Platforms
- Android (minimum Android 10, API level 29)
- iOS (minimum iOS 27 beta)

### Requirements
- Flutter (minimum version: 3.44.0)

- An operational indoor site configured with Pinpoint's EasyPlan, including its site ID
- A `.bin` file that was created with EasyPlan (see the EasyPlan manual for details)
- A valid Pinpoint license key and access credentials to Pinpoint's SDK repository
- For native UWB positioning: An UWB supported phone, e.g. iPhone 12 and newer (no iPhone SEs or E versions) or Google Pixel 8 Pro, 9 Pro or 10 Pro
- A phone with internet access


### Setup Environment
To be able to import the `pinpoint_sdk` package in your Flutter application, add the following to the `pubspec.yaml`:
```yaml
pinpoint_sdk: 
    hosted: https://posie.pinpoint.de:8073/repository/flutter_sdk_release
    version: 15.0.0+2
```


#### Add Credentials for SDK Repository
You need to add your credentials to Pinpoint's SDK repository to be able to import the the library. 

##### Android
Add the following to the `local.properties` of your app (`your_app/android/local.properties`) to be able to build it:
  ```properties
    PINPOINT_USER=<yourUserName>
    PINPOINT_PASSWORD=<yourPassword>
  ```
Note: If you do not find a file called `local.properties`, you need to run `flutter pub get` once.

##### iOS
1. Update your registry:

   ```bash
   swift package-registry set --global https://posie.pinpoint.de:8073/repository/ios_sdk_release/
   ```

   `~/Library/org.swift.swiftpm/configuration/registries.json` should look like this:

   ```json
   {
     "registries" : {
       "[default]" : {
         "supportsAvailability" : false,
         "url" : "https://posie.pinpoint.de:8073/repository/ios_sdk_release/"
       }
     },
     "version" : 1
   }
   ```

2. Add your credentials to Keychain
   ```bash
   swift package-registry login https://posie.pinpoint.de:8073/repository/ios_sdk_release/login --username <username>
   ```


#### Platform specific requirements
Below are some more Android and iOS specifics that are required for the plugin to work correctly.

<details>
<summary>Android</summary>

##### Requirements for Positioning with Native UWB
  - Minimum Android 17 (API level 37)
  - A phone with native UWB DL-TDoA support 

##### Requirements for Positioning with a TRACElet
- A Pinpoint TRACElet
- Minimum Android 10 (API level 29)

  
**AndroidX** 

The `pinpoint_sdk` plugin requires the AndroidX version of the Android Support Libraries. This means you need to make sure your Android project supports AndroidX. Detailed instructions can be found [here](https://flutter.dev/docs/development/packages-and-plugins/androidx-compatibility). 

The TL;DR version is:

1. Add the following to your "gradle.properties" file:

```properties
android.useAndroidX=true
android.enableJetifier=true
```
2. Make sure you set the `compileSdkVersion` in your "android/app/build.gradle" file to 37:

in android/app/build.gradle:

```gradle
android {
  compileSdkVersion 37
}

```

or if applicable in android/app/build.gradle.kts

```kts
android {
  compileSdk = 37
}
```

3. Make sure you replace all the `android.` dependencies to their AndroidX counterparts (a full list can be found [here](https://developer.android.com/jetpack/androidx/migrate)).

**Minimum SDK**

Make sure to set the minimum supported Android version to Android 10 (API level 29):

in android/app/build.gradle:

```gradle
defaultConfig {
  minSdkVersion 29
}
````

or if applicable in android/app/build.gradle.kts:
```kts
defaultConfig {
  minSdk = 29
}
```

**Permissions**

You'll need to add the following permissions to your Android Manifest. Open the AndroidManifest.xml file (located under `android/app/src/main`) and add the following lines as direct children of the `<manifest>` tag:

``` xml
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <!--    Needed to for the license key check-->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <!-- For Android 11 and below -->
     <uses-permission android:name="android.permission.BLUETOOTH"
                     android:maxSdkVersion="30" />
    <uses-permission
        android:name="android.permission.BLUETOOTH_ADMIN"
        android:maxSdkVersion="30"/>

    <!-- For Android 12 and above -->
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    <uses-permission
        android:name="android.permission.BLUETOOTH_SCAN"/>

```
#### Positioning with Native UWB
If you want to support positioning with native UWB, you also need this permission:
``` xml
    <uses-permission android:name="android.permission.RANGING" />
```

#### Positioning in the Background

> **IMPORTANT**:  This library currently does **not** provide any background positioning functionality. The information below is provided for reference only and is 
intended for developers who want to implement the background functionality on 
their own.

To keep positioning active while the app is running in the background, you must 
implement a foreground service. For more information on implementing and starting a foreground service, 
 refer to the example app and [Google's documentation](https://developer.android.com/develop/background-work/services/fgs).
 You have to use the `connectedDevice` and `location` service types. The 
 corresponding permissions must also be declared in your app's manifest:

``` xml
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_CONNECTED_DEVICE"/> 
```

If your app needs to start the positioning service while running in the background, you must declare the following permission:

``` xml
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/> 
````

</details>

<details>
<summary>iOS</summary>

Until iOS 27 is officially released, building for iOS 27 requires using Xcode beta. In this case, ensure that the command line tools are configured to use Xcode beta.

On iOS you'll need to add the following entry to your Info.plist file (located under ios/Runner) in order to access the device's location. Simply open your Info.plist file and add the following (make sure you update the description so it is meaningful in the context of your App):

``` xml
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>This app needs access to location when open.</string>
    <key>NSBluetoothAlwaysUsageDescription</key>
    <string>This app needs Bluetooth to scan for and connect to Pinpoint Devices.</string>
    <!-- legacy for iOS 12 and lower -->
    <key>NSBluetoothPeripheralUsageDescription</key>
    <string>This app needs Bluetooth to scan for and connect to Pinpoint Devices.</string>
```
Add the following to the `ios/Podfile` of your application:
```
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)', 'PERMISSION_BLUETOOTH=1',]
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
    if target.name == "geolocator_apple"
          target.build_configurations.each do |config|
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'BYPASS_PERMISSION_LOCATION_ALWAYS=1',]
          end
    end
  end
end

```

If you do want to receive updates when your App is in the background (or if you don't bypass the permission request as described above) then you'll need to:
* Add the Background Modes capability to your XCode project (Project > Signing and Capabilities > "+ Capability" button) and select Location Updates. Be careful with this, you will need to explain in detail to Apple why your App needs this when submitting your App to the AppStore. If Apple isn't satisfied with the explanation your App will be rejected.
* Add an `NSLocationAlwaysAndWhenInUseUsageDescription` entry to your Info.plist (use `NSLocationAlwaysUsageDescription` if you're targeting iOS <11.0) 

When using the `requestTemporaryFullAccuracy({purposeKey: "YourPurposeKey"})` method, a dictionary should be added to the Info.plist file.
```xml
<key>NSLocationTemporaryUsageDescriptionDictionary</key>
<dict>
  <key>YourPurposeKey</key>
  <string>The example App requires temporary access to the device&apos;s precise location.</string>
</dict>
```
The second key (in this example called `YourPurposeKey`) should match the purposeKey that is passed in the `requestTemporaryFullAccuracy()` method. It is possible to define multiple keys for different features in your app. More information can be found in Apple's [documentation](https://developer.apple.com/documentation/bundleresources/information_property_list/nslocationtemporaryusagedescriptiondictionary).

> NOTE: the first time requesting temporary full accuracy access it might take several seconds for the pop-up to show. This is due to the fact that iOS is determining the exact user location which may take several seconds. Unfortunately this is out of our hands.
</details>


## Usage
1. Install the Pinpoint SDK by following the instructions from [Getting started](#getting-started). Pay attention to the [platform specific requirements](#platform-specific-requirements).
2. Import it:

   ```dart
   import 'package:pinpoint_sdk/pinpoint_sdk.dart';
   ```
3. Call `Geolocator.initialize` with your API key and the callbacks for changes 
in the license token validity. This function needs to be called before using any Geolocator functionality. 
As of a now a license token of two weeeks validity will be created when the 
initialization function is called with a valid license key. The tokens will be
automatically refreshed once a day if an internet connection is available. Two 
days 
   ``` dart 
    import 'package:pinpoint_sdk/pinpoint_sdk.dart';
   
    // initializes the Geolocator class
    Geolocator.initialize(
        licenseKey: 'myLicenseKey', 
        onTokenExpired: () {
           // Tell the user to turn on their internet connection
        }, 
        onTokenExpiring: (seconds) {
          // Notify the user that they will soon have to turn on their internet
    },)
    
   ```
   If you do not call this function, an exception (`MissingInitializationException`) will be thrown.

4. Make sure that you know the site ID of your site and that you have a `.bin`
file created via EasyPlan.

5. Check the required permissions with `Geolocator.checkLocationPermission` and
`Geolocator.checkIndoorPermission`. Request them with `Geolocator.requestLocationPermission``
and `Geolocator.requestIndoorPermission` respectively.

5. Call `Geolocator.getPositionStream` or `Geolocator.getCurrentPosition` for
position updates.


### Migration from geolocator
1. Remove `geolocator` from the dependencies of your app by deleting it from the dependencies in your pubspec.yaml or by calling `flutter pub remove geolocator`

2. Follow the steps from above ([Usage](#usage)). Pay attention to the [platform
specific requirements](#platform-specific-requirements). .

3. Replace the original imports of `package:geolocator/geolocator.dart` with `package:pinpoint_sdk/pinpoint_sdk.dart`

4. If you are using the function `getServiceStatusStream`, pay attention that the type changed, more information [here](#service-status). 

5. If you are using location settings with a distance filter: Make sure to convert it from meters to centimeters. Keep in mind that the function `getCurrentPosition` ignores any distance filter.


### Example

The code below shows an example on how to listen to position updates of the 
device, including checking if the location services are enabled and checking / requesting permissions to access the position of the device:

```dart
import 'package:pinpoint_sdk/pinpoint_sdk.dart';

/// Determine the current position of the device.
///
/// If the location services or Bluetooth are not enabled or the permissions 
/// were denied the `Future` will return an error.
Future<void> _startPositioning() async {
  
  // Test if all conditions for positioning are fulfilled.
  final serviceStatus = await Geolocator.getServiceStatus();

  if (serviceStatus?.locationEnabled != true) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the 
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  if (serviceStatus?.bluetoothEnabled != true) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the 
    // App to enable the location services.
    return Future.error('Bluetooth is disabled.');
  }

  LocationPermission locationPermission = await Geolocator.checkLocationPermission();
  if (locationPermission == LocationPermission.denied) {
    locationPermission = await Geolocator.requestPermission();
    if (locationPermission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale 
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.)
      return Future.error('Location permissions are denied');
    }
  }

  if (locationPermission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately. 
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 

  LocationPermission indoorLocationPermission = await Geolocator.checkIndoorPermission();
  if (indoorLocationPermission == LocationPermission.denied) {
    indoorLocationPermission = await Geolocator.requestPermission();
    if (indoorLocationPermission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale 
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.)
      return Future.error('Indoor location permissions are denied');
    }
  }


  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  // Tell your users to hold their TRACElet close to the device if applicable
  Geolocator.getPositionStream(
      binFile: yourBinFile, // as Uint8List
      siteId: 0x1234, // replace with your site ID
  ).listen(position) {
    // do something with the position
  }.handleError(dynamic error) {
    // handle possible exceptions
  } 
}
```

## API

#### Initialize Geolocator
Before being able to use any of the API functions, you need to call the function `initialize` with your license key. Your license key will validated and an offline token for two weeks will be created. This requires a working internet connection. The tokens will be automatically refreshed once a day if an internet connection is available. 
To handle the unlikely case that the tokens could not be refreshed because no internet connection was available for two weeks, you need to provide two callbacks.

```dart
// Initialize Geolocator
await Geolocator.initialize(
  licenseKey: licenseKey,
  onTokenExpired: () {
    // positioning will not be possible anymore
    // tell your user to turn on iternet and try again
  },
  onTokenExpiring: (seconds) {
    // Positioning is still possible, but only for two days maximum
    // Tell your user to turn on internet
  },
)
  
  
```


### Geolocation

#### Last known location

To query the last known location stored on the device you can use the `getLastKnownPosition` method (note that this can result in a `null` value when no location details are available).

``` dart
import 'package:pinpoint_sdk/pinpoint_sdk.dart';

Position? position = await Geolocator.getLastKnownPosition();
```

Note: Positions that were determined by the indoor location service are 
instances of the class `IndoorPosition`. 

#### Current location

To query the current location of the device simply make a call to the `getCurrentPosition` method. You can finetune the results by specifying [location settings](#location-settings). 

You need to provide a `.bin` file created by EasyPlan and the site ID of 
your site. Refer to the user manual for more details. 

``` dart

final LocationSettings locationSettings = LocationSettings(
  // only applies for outdoor positions
  accuracy: LocationAccuracy.high,
  // applies for both indoor and outdoor positions
  timeLimit: const Duration(seconds 15),
);

Position position = await Geolocator.getCurrentPosition(
  locationSettings: locationSettings,
  binFile: yourBinFile,
  siteId: yourSiteID
);
```

Note: Positions that were determined by the indoor location service are 
instances of the class `IndoorPosition`.


#### Listen to location updates

To listen for location changes you can call  `getPositionStream` to receive a stream with position updates. 

Positions that were determined by the indoor location service are instances of 
the class `IndoorPosition`.

You need to provide a `.bin` file created by EasyPlan and the site ID of your 
site. Refer to the user manual for more details. 

You can control the settings used for retrieving the location by supplying 
[location settings](#location-settings).


``` dart
final LocationSettings locationSettings = LocationSettings(
  // only applies for outdoor positions
  accuracy: LocationAccuracy.high,
  // applies for both indoor and outdoor positions
  distanceFilter: 30,
);
StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
  locationSettings: locationSettings,
  binFile: yourBinFile,
  siteId: yourSiteId,

).listen(
    (Position position) {
       // Do something with the position
    }
);
```
#### Location Settings
You can finetune the results from `getPositionStream` and `getCurrentPosition` by specifying the following parameters:
- `accuracy`: the accuracy of the location data that your app wants to receive (applies only for outdoor positions)
- `distanceFilter`: the minimum distance (measured in centimeters) a device must move horizontally before an update event is generated:
  
  **Note**:  The distance filter in geolocator is measured in meters. This package uses centimeters to allow smaller distance filters for indoor positions.

- `timeLimit`: the maximum amount of time allowed between location updates. When the time limit is passed a `TimeoutException` will be thrown and the stream will be cancelled. By default no limit is configured. <br><br> **Note:** If there is not any active subscription to the stream returned by `getPositionStream`, the timeout will always be increased to the minimum time it takes to start the indoor position services.

``` dart
final LocationSettings locationSettings = LocationSettings(
  // only applies for outdoor positions
  accuracy: LocationAccuracy.high,
  // applies for both indoor and outdoor positions
  distanceFilter: 30,
  // applies for both indoor and outdoor positions, but only after the indoor positioning service was initialized
  timeLimit: const Duration(seconds 15)
);

```

##### Restrictions of the location settings
- If you set a distance filter in the location settings, it will be ignored in `getCurrentPosition`.
- When calling `getCurrentPosition` with location settings, time limits are always increased to the minimum time it takes to start the indoor position service (10 seconds). 
- If you called `getPositionStream` before and have not cancelled all subscriptions to the stream, the location settings will not be updated when calling `getCurrentPosition`. The same applies if you call `getPositionStream` a second time.


##### Notes on the location accuracy 
The location accuracy for indoor position is always `LocationAccuracy.highest`. For outdoor positions the following applies:

<details>
<summary>Android</summary> 
On Android, the `LocationAccuracy` enum controls the accuracy of the location data the app wants to receive. It also provides control over the [priority given to the location stream](https://developers.google.com/android/reference/com/google/android/gms/location/Priority). This can be confusing, as a priority of **lowest** might not return any location, while one might expect it to give the quickest responses. The table below outlines the priority and its meaning per accuracy option:

| Location accuracy | Android priority | Description |
|-------------------|------------------|-------------|
| **lowest**        | [PRIORITY_PASSIVE](https://developers.google.com/android/reference/com/google/android/gms/location/Priority#public-static-final-int-priority_passive) | Ensures that no extra power will be used to derive locations. This enforces that the request will act as a passive listener that will only receive "free" locations calculated on behalf of other clients, and no locations will be calculated on behalf of only this request. |
| **low**           | [PRIORITY_LOW_POWER](https://developers.google.com/android/reference/com/google/android/gms/location/Priority#public-static-final-int-priority_low_power) | Requests a tradeoff that favors low power usage at the possible expense of location accuracy. |
| **medium**        | [PRIORITY_BALANCED_POWER_ACCURACY](https://developers.google.com/android/reference/com/google/android/gms/location/Priority#public-static-final-int-priority_balanced_power_accuracy) | Requests a tradeoff that is balanced between location accuracy and power usage. |
| **high**+         | [PRIORITY_HIGH_ACCURACY](https://developers.google.com/android/reference/com/google/android/gms/location/Priority#public-static-final-int-priority_high_accuracy) | Requests a tradeoff that favors highly accurate locations at the possible expense of additional power usage. |
</details>

<details>
<summary>iOS</summary>
On iOS, the `LocationAccuracy` enum controls the accuracy of the location data the app wants to receive. It also provides control on the battery consumption of the device: the more detailed data is requested, the larger the impact on the battery consumption. More details can be found on [Apple's documentation](https://developer.apple.com/documentation/corelocation/cllocationmanager/1423836-desiredaccuracy?language=objc). The table below shows how the `LocationAccuracy` values map to the native iOS accuracy settings.

| Location accuracy | iOS accuracy | Description |
|---|---|---|
| **lowest** | [kCLLocationAccuracyThreeKilometers](https://developer.apple.com/documentation/corelocation/kcllocationaccuracythreekilometers?language=objc) | Accurate to the nearest three kilometers. |
| **low** | [kCLLocationAccuracyKilometer](https://developer.apple.com/documentation/corelocation/kcllocationaccuracykilometer?language=objc) | Accurate to the nearest kilometer. |
| **medium** | [kCLLocationAccuracyHundredMeters](https://developer.apple.com/documentation/corelocation/kcllocationaccuracyhundredmeters?language=objc) | Accurate to within one hundred meters. |
| **high** | [kCLLocationAccuracyNearestTenMeters](https://developer.apple.com/documentation/corelocation/kcllocationaccuracynearesttenmeters?language=objc) | Accurate to within ten meters of the desired target. |
| **best** | [kCLLocationAccuracyBest](https://developer.apple.com/documentation/corelocation/kcllocationaccuracybest?language=objc) | The best level of accuracy available. |
| **bestForNavigation** | [kCLLocationAccuracyBestForNavigation](https://developer.apple.com/documentation/corelocation/kcllocationaccuracybestfornavigation?language=objc) | The highest possible accuracy that uses additional sensor data to facilitate navigation apps. |
</details>

##### Platform specific location settings (Outdoor positioning only)

In certain situation it is necessary to specify some platform specific settings. This can be accomplished using the platform specific `AndroidSettings` or `AppleSettings` classes. For example:

```dart
import 'package:pinpoint_sdk/pinpoint_sdk.dart';

late LocationSettings locationSettings;

if (defaultTargetPlatform == TargetPlatform.android) {
  locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      forceLocationManager: true,
      intervalDuration: const Duration(seconds: 10),
      //(Optional) Set foreground notification config to keep the app alive 
      //when going to the background
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationText:
        "Example app will continue to receive your location even when you aren't using it",
        notificationTitle: "Running in Background",
        enableWakeLock: true,
      )
  );
} else if (defaultTargetPlatform == TargetPlatform.iOS) {
  locationSettings = AppleSettings(
    accuracy: LocationAccuracy.high,
    activityType: ActivityType.fitness,
    pauseLocationUpdatesAutomatically: true,
    // Only set to true if our app will be started up in the background.
    showBackgroundLocationIndicator: false,
  );
} else {
  locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 30,
  );
}

// supply location settings to getCurrentPosition
Position position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);

// supply location settings to getPositionStream
StreamSubscription<Position> positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (Position position) {
      print('${position.latitude.toString()}, ${position.longitude.toString()}');
    });
```

#### Location accuracy for outdoor positions

To query if a user enabled Approximate location fetching or Precise location fetching, you can call the `Geolocator().getLocationAccuracy()` method. This will return a `Future<LocationAccuracyStatus>`, which when completed contains a `LocationAccuracyStatus.reduced` if the user has enabled Approximate location fetching or `LocationAccuracyStatus.precise` if the user has enabled Precise location fetching.
When calling `getLocationAccuracy` before the user has given permission, the method will return `LocationAccuracyStatus.reduced` by default.

``` dart
final accuracy = await Geolocator.getLocationAccuracy();
```

#### Service status

> **ATTENTION:** The service status in the Pinpoint SDK differs from the one in the geolocator package.

The `ServiceStatus` class contains information on the preconditions for 
positioning. Call `getServiceStatus` to get the current value. You can determine the 
following:
* Is Bluetooth enabled or disabled?
* Are the location services enabled?
* Is a TRACElet connected?
* Android 17 only: is UWB enabled?

Values that are not determinable (e.g. because of missing permissions) are null.

Call or `getServiceStatusStream` to listen to continuous updates:

```dart
ServiceStatus? previousStatus;
Geolocator.getServiceStatusStream().listen(serviceStatus) {
  if (previousStatus == null) {
      // handle the initial status
  } else if (serviceStatus.bluetoothEnabled != previousStatus!.bluetoothEnabled) {
    // handle Bluetooth change
  } else if (serviceStatus.locationEnabled !=
            previousStatus!.locationEnabled &&) {
    // handle location service change
    
  } else if (serviceStatus.traceletConnected != previousStatus!.traceletConnected) {
      // handle TRACElet connection or disconnection
  } else if (serviceStatus.uwbEnabled != previousStatus!.uwbEnabled) {
      // handle UWB change
  }
};

```


### Permissions

If you want to check if the user already granted the necessary permissions to 
enable positioning, you can call `checkLocationPermission` for the permissions
required by geolocator and `checkIndoorPermission` for the ones that are 
**additionally** required for indoor positioning: 

``` dart
LocationPermission permission = await Geolocator.checkLocationPermission();
LocationPermission indoorPermission = await Geolocator.checkIndoorPermission();
```

If you want to request the permissions call `Geolocator.requestLocationPermission` 
and `requestIndoorPermission`.:

``` dart
LocationPermission permission = await Geolocator.requestLocationPermission();
LocationPermission indoorPermission = await Geolocator.checkLocationPermission();

```



Possible results from the `checkPermission` and `requestPermission` methods are:

Permission | Description
-----------|------------
denied | Permission to access the device's location or Bluetooth is denied by the user. You are free to request permission again (this is also the initial permission state).
deniedForever | Permission to access the device's location or Bluetooth is permanently denied. When requesting permissions the permission dialog will not be shown until the user updates the permission in the App settings.
whileInUse | Permission to access the device's location or Bluetooth is allowed only while the App is in use.
always | Permission to access the device's location or Bluetooth is allowed even when the App is running in the background.

> Note: Android can only return `whileInUse`, `always` or `denied` when checking permissions. Due to limitations on the Android OS it is not possible to determine if permissions are denied permanently when checking permissions. Using a workaround the geolocator is only able to do so as a result of the `requestPermission` method. More information can be found in geolocator's [wiki](https://github.com/Baseflow/flutter-geolocator/wiki/Breaking-changes-in-7.0.0#android-permission-update).

### Device Settings

In some cases it is necessary to ask the user and update their device settings. For example when the user initially permanently denied permissions to access the device's location or if the location services are not enabled (and, on Android, automatic resolution didn't work). In these cases you can use the `openAppSettings` or `openLocationSettings` methods to immediately redirect the user to the device's settings page. 

On Android the `openAppSettings` method will redirect the user to the App specific settings where the user can update necessary permissions. The `openLocationSettings` method will redirect the user to the location settings where the user can enable/ disable the location services.

On iOS we are not allowed to open specific setting pages so both methods will redirect the user to the Settings App from where the user can navigate to the correct settings category to update permissions or enable/ disable the location services.

``` dart
await Geolocator.openAppSettings();
await Geolocator.openLocationSettings();
```

### Utility Methods

To calculate the distance meters between two geocoordinates you can use the 
`distanceBetween` method. The `distanceBetween` method takes four parameters:

Parameter | Type | Description
----------|------|------------
startLatitude | double | Latitude of the start position
startLongitude | double | Longitude of the start position
endLatitude | double | Latitude of the destination position
endLongitude | double | Longitude of the destination position

``` dart
double distance = Geolocator.distanceBetween(52.2165157, 6.9437819, 52.3546274, 4.8285838);
```

If you want to calculate the bearing between two geocoordinates you can use the `bearingBetween` method. The `bearingBetween` method also takes four parameters:

Parameter | Type | Description
----------|------|------------
startLatitude | double | Latitude of the start position
startLongitude | double | Longitude of the start position
endLatitude | double | Latitude of the destination position
endLongitude | double | Longitude of the destination position

``` dart
double bearing = Geolocator.bearingBetween(52.2165157, 6.9437819, 52.3546274, 4.8285838);
```

### Logging
The Pinpoint SDK uses the Dart [logging](https://pub.dev/packages/logging) framework. All logs from the SDK start with the prefix `pinpoint_sdk`. 

``` dart
hierarchicalLoggingEnabled = true;
// listen only to logs by the Pinpoint SDK
Logger('pinpoint_sdk').onRecord.listen(
  (record) {
    print('${record.time} [${record.loggerName}] ${record.message}');
  },
);

```


## Troubleshooting 
### "I do not get any positions"
- Make sure that you have enabled both Bluetooth and Location service.
- Note that it might take up to 10 seconds before you receive the first position. 
if you are using `getCurrentPosition`.
- Make sure that your app has all the [necessary permissions](#setup-environment).
- If you are using an external TRACElet, hold it close to your phone.
- Check the [service status](#service-status) to see if your TRACElet disconnected. in that case, 
cancel your subscriptions to the position stream. Notify your user to turn on 
their TRACElet and then resubscribe to the stream. 


## License
This package is licensed under a proprietary license with MIT licensed components. Please refer to the [LICENSE file](https://pub.dev/packages/pinpoint_sdk/license) for more details. 
