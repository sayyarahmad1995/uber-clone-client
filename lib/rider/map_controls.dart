import 'package:google_maps_flutter/google_maps_flutter.dart';

CameraUpdate recenterCamera(LatLng target) => CameraUpdate.newLatLng(target);

CameraPosition northUpCamera(CameraPosition current) => CameraPosition(
  target: current.target,
  zoom: current.zoom,
  bearing: 0,
  tilt: 0,
);
