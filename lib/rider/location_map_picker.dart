import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../configurations/google_maps.dart';
import '../theme.dart';
import '../widgets/auth_shell.dart';
import 'rider_demo_data.dart';
import 'places_api.dart';

typedef LocationMapBuilder =
    Widget Function(
      BuildContext context,
      LatLng initial,
      ValueChanged<LatLng> onMove,
      VoidCallback onReady,
    );

class LocationMapPicker extends StatefulWidget {
  const LocationMapPicker({
    super.key,
    required this.pickup,
    required this.initial,
    this.mapBuilder,
    this.repository,
  });
  final bool pickup;
  final PlacesRepository? repository;
  final RiderPlace initial;
  final LocationMapBuilder? mapBuilder;
  @override
  State<LocationMapPicker> createState() => _LocationMapPickerState();
}

class _LocationMapPickerState extends State<LocationMapPicker> {
  late LatLng _point;
  GoogleMapController? _controller;
  Timer? _timeout;
  bool _ready = false, _failed = false, _confirming = false;

  bool get _available =>
      widget.mapBuilder != null ||
      (GoogleMapsConfiguration.mapsEnabled &&
          (kIsWeb || defaultTargetPlatform == TargetPlatform.android));
  String get _label => widget.pickup ? 'pickup' : 'destination';
  @override
  void initState() {
    super.initState();
    _point = LatLng(widget.initial.latitude, widget.initial.longitude);
    if (_available) {
      _timeout = Timer(const Duration(seconds: 20), () {
        if (mounted && !_ready) setState(() => _failed = true);
      });
    }
  }

  void _onReady() {
    _timeout?.cancel();
    if (mounted) setState(() => _ready = true);
  }

  void _onMove(LatLng point) => setState(() => _point = point);
  @override
  void dispose() {
    _timeout?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final point = _point;
    setState(() => _confirming = true);
    var place = RiderPlace(
      'map-${point.latitude}-${point.longitude}',
      'Selected map location',
      '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}',
      point.latitude,
      point.longitude,
    );
    try {
      if (widget.repository != null) {
        final address = await widget.repository!.reverse(
          point.latitude,
          point.longitude,
        );
        place = RiderPlace(
          place.id,
          address.name,
          place.address,
          point.latitude,
          point.longitude,
        );
      }
    } catch (_) {
      // A missing address must not prevent confirming an exact free pin.
    }
    if (mounted) Navigator.pop(context, place);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: MobileFrame(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  BackButton(),
                  Expanded(
                    child: Text(
                      'Set $_label',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (!_available || _failed)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.map_outlined,
                              color: hiGoPurple,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Map is unavailable',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const Text(
                              'Go back to search for a place, or try again when the map is available.',
                              textAlign: TextAlign.center,
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Back to search'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    Positioned.fill(
                      child:
                          widget.mapBuilder?.call(
                            context,
                            _point,
                            _onMove,
                            _onReady,
                          ) ??
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _point,
                              zoom: 16,
                            ),
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            compassEnabled: false,
                            mapToolbarEnabled: false,
                            webCameraControlEnabled: false,
                            fullscreenControlEnabled: false,
                            onCameraMove: (camera) => _onMove(camera.target),
                            onMapCreated: (controller) {
                              _controller = controller;
                              _onReady();
                            },
                          ),
                    ),
                    const IgnorePointer(
                      child: FractionalTranslation(
                        translation: Offset(0, -.5),
                        child: Icon(
                          Icons.location_pin,
                          color: hiGoPurple,
                          size: 48,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Move map to set $_label',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Selected map location'),
                  Text(
                    '${_point.latitude.toStringAsFixed(5)}, ${_point.longitude.toStringAsFixed(5)}',
                    style: const TextStyle(
                      color: Color(0xFF858BA1),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    key: const Key('confirm-map-location'),
                    onPressed: !_ready || _failed || _confirming
                        ? null
                        : _confirm,
                    child: Text(
                      _confirming ? 'Confirming…' : 'Confirm $_label',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
