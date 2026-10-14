import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideRoutePreview {
  const RideRoutePreview(
    this.distanceMeters,
    this.durationSeconds,
    this.points,
  );
  final double distanceMeters, durationSeconds;
  final List<LatLng> points;
  factory RideRoutePreview.fromJson(Map<String, dynamic> json) {
    final route = json['route'] as Map<String, dynamic>;
    final meters = (route['distance_meters'] as num).toDouble();
    final seconds = (route['duration_seconds'] as num).toDouble();
    if (!meters.isFinite || !seconds.isFinite || meters < 0 || seconds < 0) {
      throw const FormatException('Invalid route metrics');
    }
    final encoded = route['encoded_polyline'] as String;
    var index = 0, lat = 0, lng = 0;
    int component() {
      var result = 0, shift = 0, value = 0;
      do {
        if (index >= encoded.length || shift > 30) {
          throw const FormatException('Invalid route');
        }
        value = encoded.codeUnitAt(index++) - 63;
        if (value < 0 || value > 63) {
          throw const FormatException('Invalid route');
        }
        result |= (value & 31) << shift;
        shift += 5;
      } while (value >= 32);
      return (result & 1) != 0 ? ~(result >> 1) : result >> 1;
    }

    final points = <LatLng>[];
    while (index < encoded.length) {
      lat += component();
      lng += component();
      if ((lat / 1e5).abs() > 90 || (lng / 1e5).abs() > 180) {
        throw const FormatException('Invalid route');
      }
      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    if (points.length < 2) throw const FormatException('Missing route');
    return RideRoutePreview(meters, seconds, points);
  }
}
