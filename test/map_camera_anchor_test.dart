import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:higo_countrycode/rider/map_camera_anchor.dart';

void main() {
  const location = LatLng(33.7095, 73.0375);
  const panned = LatLng(33.72, 73.055);
  test('a pan changes the resize anchor until explicit recenter', () {
    final anchor = MapCameraAnchor(location);
    expect(anchor.resizeTarget, location);
    anchor.cameraMoved(panned);
    expect(anchor.followingLocation, isFalse);
    expect(anchor.resizeTarget, panned);
    anchor.cameraMoved(const LatLng(33.725, 73.06));
    expect(anchor.resizeTarget, const LatLng(33.725, 73.06));
    anchor.recenterOnLocation();
    expect(anchor.followingLocation, isTrue);
    expect(anchor.resizeTarget, location);
  });
  test('app camera updates and centered zoom do not disable following', () {
    final anchor = MapCameraAnchor(location);
    anchor.cameraMoved(panned, programmatic: true);
    expect(anchor.followingLocation, isTrue);
    expect(anchor.resizeTarget, location);
    anchor.cameraMoved(location);
    expect(anchor.followingLocation, isTrue);
  });
  test(
    'a destination stays selected across resize and app movement callbacks',
    () {
      final anchor = MapCameraAnchor(location);
      anchor.showDestination(panned);
      anchor.cameraMoved(location, programmatic: true);
      expect(anchor.followingLocation, isFalse);
      expect(anchor.resizeTarget, panned);
      anchor.recenterOnLocation();
      expect(anchor.resizeTarget, location);
    },
  );
}
