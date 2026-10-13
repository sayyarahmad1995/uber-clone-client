import 'package:flutter/foundation.dart';

abstract final class GoogleMapsConfiguration {
  // Android's key is supplied by Gradle from android/secretes.properties.
  // Web still uses the setup helper to generate its JavaScript configuration.
  static const mapsEnabled = bool.fromEnvironment(
    'MAPS_CONFIGURED',
    defaultValue: !kIsWeb,
  );
}
