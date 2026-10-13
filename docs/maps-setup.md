# Google Maps setup

Keys are read from `android/secretes.properties` (the requested spelling). This file and generated `web/maps-config.js` are ignored by Git. An empty example is tracked at `android/secretes.properties.example`.

```properties
GOOGLE_MAPS_API_KEY=your_android_key
GOOGLE_MAPS_WEB_API_KEY=your_web_key
```

Use the Android Maps SDK key for Android and a Maps JavaScript API key for web. Enable the respective APIs and billing in your Google Cloud project. Restrict the Android key to `com.higo.higo_countrycode` and the signing certificate fingerprint; restrict the web key to your allowed origins, including your local development origin. Actual keys are embedded in compiled clients when used, so platform restrictions are essential; ignoring the file keeps them out of source control rather than making client keys secret.

From the project root:

```powershell
flutter pub get
dart run tool/run_maps.dart android run -d emulator-5554 --route=/rider
dart run tool/run_maps.dart web run -d chrome --web-port=5174 --route=/rider
```

Build commands:

```powershell
flutter build apk --release
dart run tool/run_maps.dart web build --no-web-resources-cdn --no-wasm-dry-run
```

The tool reads only the selected platform key, sets the configured flag for Flutter, and generates the ignored web loader configuration when needed. Gradle reads the Android key from the same properties file into a manifest placeholder. Native maps are enabled by default in lib/configurations/google_maps.dart, so standard Android builds need no Dart flag. The optional MAPS_CONFIGURED override remains available; the helper uses it to show the setup state when a key is missing.

When launched through the helper without a key, the UI shows a map setup state. Standard Android builds require a valid key in the properties file; they attempt to load the map by default. A map that does not initialize within 20 seconds offers retry. A controller can initialize even if tiles are denied: if the map remains blank, check your API enablement, billing, application restrictions, signing fingerprint, connection and platform logs. Avoid copying keys or key-bearing URLs into logs/issues.

Real map tiles are supported here on Android and web. iOS remains unconfigured; Windows desktop displays the setup state with guidance to use a browser.

The map starts at a sample F-8 Islamabad position. Nearby cars, places, profile and destination selection are demo data. No GPS permission is requested, no booking occurs, and no Go backend request is sent.

Map layout keeps the map viewport above the sheet because the web plugin does not move attribution controls with padding. Pointer interception protects Flutter overlays from the web map consuming their input.

References: https://developers.google.com/maps/flutter-package/config and https://pub.dev/packages/google_maps_flutter_web

For an Android release with live maps, save the key in android/secretes.properties and run flutter build apk --release. Web still needs the setup helper to generate its JavaScript key configuration.



