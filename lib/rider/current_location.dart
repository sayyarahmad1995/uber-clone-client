import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'rider_demo_data.dart';

typedef CurrentLocationLoader = Future<RiderPlace> Function();

class LocationFailure implements Exception {
  const LocationFailure(this.message);
  final String message;
}

Future<RiderPlace> loadCurrentLocation() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationFailure(
        'Turn on location services, or search or choose on map.',
      );
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationFailure(
        'Location permission is off. You can still search or choose on map.',
      );
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return RiderPlace(
      'device-location',
      'Current location',
      '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
      position.latitude,
      position.longitude,
    );
  } on LocationFailure {
    rethrow;
  } on TimeoutException {
    throw const LocationFailure(
      'Location took too long. Try again, search, or choose on map.',
    );
  } catch (_) {
    throw const LocationFailure(
      'Could not get your location. Search or choose on map instead.',
    );
  }
}
