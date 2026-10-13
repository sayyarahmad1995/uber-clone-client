import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:higo_countrycode/rider/map_controls.dart';

void main() {
  test('recenter changes only the target, without specifying zoom', () {
    const target = LatLng(33.7, 73.0);
    expect(
      recenterCamera(target).toJson(),
      CameraUpdate.newLatLng(target).toJson(),
    );
  });
  test(
    'north up preserves position and zoom while clearing tilt and bearing',
    () {
      const current = CameraPosition(
        target: LatLng(33.72, 73.06),
        zoom: 17.4,
        tilt: 50,
        bearing: 130,
      );
      final reset = northUpCamera(current);
      expect(reset.target, current.target);
      expect(reset.zoom, current.zoom);
      expect(reset.tilt, 0);
      expect(reset.bearing, 0);
    },
  );
}
