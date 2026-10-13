import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Remembers the view chosen by the rider independently of viewport resizing.
class MapCameraAnchor {
  MapCameraAnchor(this.location) : _viewTarget = location;
  final LatLng location;
  LatLng _viewTarget;
  bool followingLocation = true;

  LatLng get resizeTarget => followingLocation ? location : _viewTarget;

  void cameraMoved(LatLng target, {bool programmatic = false}) {
    if (programmatic) return;
    _viewTarget = target;
    if ((target.latitude - location.latitude).abs() > .000001 ||
        (target.longitude - location.longitude).abs() > .000001) {
      followingLocation = false;
    }
  }

  void recenterOnLocation() {
    followingLocation = true;
    _viewTarget = location;
  }

  void showDestination(LatLng target) {
    followingLocation = false;
    _viewTarget = target;
  }
}
