import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme.dart';
import '../configurations/google_maps.dart';
import 'rider_demo_data.dart';
import 'viewport_centering.dart';
import 'map_camera_anchor.dart';
import 'camera_animation.dart';
import 'map_controls.dart';

class RiderMap extends StatefulWidget {
  const RiderMap({
    super.key,
    required this.bottomInset,
    required this.recenterRequest,
    this.northUpRequest = 0,
    this.destination,
    this.pickup,
    this.configured = GoogleMapsConfiguration.mapsEnabled,
  });
  final double bottomInset;
  final int recenterRequest;
  final int northUpRequest;
  final RiderPlace? destination, pickup;
  final bool configured;
  @override
  State<RiderMap> createState() => _RiderMapState();
}

class _RiderMapState extends State<RiderMap> {
  GoogleMapController? _controller;
  BitmapDescriptor? _car, _dot;
  Timer? _timeout;
  bool _failed = false, _ready = false;
  int _attempt = 0;
  int _cameraCommands = 0;
  final _animation = CameraAnimation();
  CameraPosition _camera = CameraPosition(target: _center, zoom: 14);
  late final _anchor = MapCameraAnchor(_center);
  late final _centering = ViewportCentering(
    scheduleAfterLayout: (callback) {
      WidgetsBinding.instance.addPostFrameCallback((_) => callback());
      WidgetsBinding.instance.ensureVisualUpdate();
    },
    center: () async {
      if (!mounted || !_ready) return;
      _animation.finish();
      _cameraCommands++;
      try {
        await _controller?.moveCamera(
          CameraUpdate.newLatLng(_anchor.resizeTarget),
        );
      } finally {
        _cameraCommands--;
      }
    },
  );
  bool get _supported =>
      kIsWeb || defaultTargetPlatform == TargetPlatform.android;
  static final _center = LatLng(demoPickup.latitude, demoPickup.longitude);

  @override
  void initState() {
    super.initState();
    if (widget.configured && _supported) {
      _start();
      _loadMarkers();
    }
  }

  void _start() {
    _timeout?.cancel();
    _timeout = Timer(const Duration(seconds: 20), () {
      if (mounted && !_ready) setState(() => _failed = true);
    });
  }

  Future<void> _loadMarkers() async {
    final car = await _markerBytes(car: true);
    final dot = await _markerBytes(car: false);
    if (!mounted) return;
    setState(() {
      _car = BitmapDescriptor.bytes(car, width: 22, height: 40);
      _dot = BitmapDescriptor.bytes(dot, width: 32, height: 32);
    });
  }

  @override
  void didUpdateWidget(covariant RiderMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recenterRequest != widget.recenterRequest) {
      _anchor.recenterOnLocation();
      _animate(recenterCamera(_center));
    }
    if (oldWidget.northUpRequest != widget.northUpRequest) {
      _animate(CameraUpdate.newCameraPosition(northUpCamera(_camera)));
    }
    if (oldWidget.destination != widget.destination &&
        widget.destination != null) {
      _anchor.showDestination(
        LatLng(widget.destination!.latitude, widget.destination!.longitude),
      );
      _moveTo(widget.destination!, zoom: 14.2);
    }
  }

  Future<void> _moveTo(RiderPlace place, {required double zoom}) async {
    await _animate(
      CameraUpdate.newLatLngZoom(LatLng(place.latitude, place.longitude), zoom),
    );
  }

  Future<void> _animate(CameraUpdate update) async {
    if (_controller == null) return;
    _animation.start();
    _cameraCommands++;
    try {
      await _controller?.animateCamera(
        update,
        duration: CameraAnimation.duration,
      );
    } catch (_) {
      _animation.finish();
      if (mounted) setState(() => _failed = true);
    } finally {
      _cameraCommands--;
    }
  }

  @override
  void dispose() {
    _centering.dispose();
    _animation.dispose();
    _timeout?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.configured || !_supported || _failed) return _fallback(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        _centering.resize(constraints.biggest);
        return Stack(
          children: [
            Listener(
              onPointerDown: (_) => _animation.finish(),
              child: GoogleMap(
                key: ValueKey('map-$_attempt'),
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 14,
                ),
                padding: EdgeInsets.only(bottom: widget.bottomInset, top: 0),
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                webCameraControlEnabled: false,
                fullscreenControlEnabled: false,
                mapToolbarEnabled: false,
                onCameraMove: (position) {
                  _camera = position;
                  _anchor.cameraMoved(
                    position.target,
                    programmatic:
                        _cameraCommands > 0 ||
                        _centering.isUpdating ||
                        _animation.active,
                  );
                },
                onCameraIdle: _animation.finish,
                style:
                    '[{"featureType":"poi.business","stylers":[{"visibility":"off"}]},{"featureType":"transit","stylers":[{"visibility":"off"}]},{"featureType":"landscape","elementType":"geometry","stylers":[{"color":"#edf1f2"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#cce6d5"}]}]',
                circles: {
                  Circle(
                    circleId: const CircleId('location-halo'),
                    center: _center,
                    radius: 160,
                    fillColor: hiGoPurple.withValues(alpha: .10),
                    strokeColor: hiGoPurple.withValues(alpha: .08),
                    strokeWidth: 1,
                  ),
                },
                markers: {
                  Marker(
                    markerId: const MarkerId('pickup'),
                    position: widget.pickup == null
                        ? _center
                        : LatLng(
                            widget.pickup!.latitude,
                            widget.pickup!.longitude,
                          ),
                    icon: _dot ?? BitmapDescriptor.defaultMarker,
                    anchor: const Offset(.5, .5),
                    infoWindow: InfoWindow(
                      title: widget.pickup?.name ?? 'F-8 map center',
                      snippet:
                          widget.pickup?.address ??
                          'Choose your pickup location',
                    ),
                  ),
                  if (_car != null)
                    for (var i = 0; i < demoCars.length; i++)
                      Marker(
                        markerId: MarkerId('car-$i'),
                        position: LatLng(demoCars[i].$1, demoCars[i].$2),
                        icon: _car!,
                        anchor: const Offset(.5, .5),
                        rotation: demoCars[i].$3,
                        flat: true,
                        infoWindow: const InfoWindow(
                          title: 'Demo nearby car',
                          snippet: 'Sample data; not a live driver',
                        ),
                      ),
                  if (widget.destination case final place?)
                    Marker(
                      markerId: const MarkerId('destination'),
                      position: LatLng(place.latitude, place.longitude),
                      icon: BitmapDescriptor.defaultMarker,
                      infoWindow: InfoWindow(
                        title: place.name,
                        snippet: 'Destination preview',
                      ),
                    ),
                },
                onMapCreated: (controller) {
                  _controller = controller;
                  _timeout?.cancel();
                  if (mounted) {
                    setState(() => _ready = true);
                  }
                  if (widget.destination != null) {
                    _anchor.showDestination(
                      LatLng(
                        widget.destination!.latitude,
                        widget.destination!.longitude,
                      ),
                    );
                    _moveTo(widget.destination!, zoom: 14.2);
                  } else {
                    _centering.recenter();
                  }
                },
              ),
            ),
            if (!_ready)
              Positioned(
                top: MediaQuery.paddingOf(context).top + 126,
                left: 20,
                child: const Chip(
                  label: Text('Loading map…'),
                  avatar: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            if (_ready)
              Positioned(
                left: 16,
                top: MediaQuery.paddingOf(context).top + 105,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .94),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Nearby cars · Demo',
                      style: TextStyle(fontSize: 9, color: Color(0xFF727B90)),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _fallback(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final visibleHeight = (constraints.maxHeight - widget.bottomInset).clamp(
        0.0,
        constraints.maxHeight,
      );
      return DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE1EEE9), Color(0xFFEAE9F8), Color(0xFFE9EDF5)],
          ),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: visibleHeight,
            child: visibleHeight < 260
                ? null
                : Padding(
                    padding: const EdgeInsets.fromLTRB(30, 105, 30, 4),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.map_outlined,
                              color: hiGoPurple,
                              size: 30,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _failed
                                  ? 'Map couldn’t load'
                                  : 'Your city, in view',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _failed
                                  ? 'Check your connection and map configuration.'
                                  : 'Connect Google Maps to explore Islamabad.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF737C93),
                              ),
                            ),
                            TextButton(
                              onPressed: _failed
                                  ? () {
                                      setState(() {
                                        _failed = false;
                                        _ready = false;
                                        _attempt++;
                                      });
                                      _start();
                                    }
                                  : () => showDialog<void>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Google Maps setup'),
                                        content: const Text(
                                          'Add your platform key to android/secretes.properties, then launch with the map setup tool described in docs/maps-setup.md. On Windows desktop, open the web version.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Got it'),
                                          ),
                                        ],
                                      ),
                                    ),
                              child: Text(_failed ? 'Retry map' : 'Map setup'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      );
    },
  );
}

Future<Uint8List> _markerBytes({required bool car}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint()..isAntiAlias = true;
  final width = car ? 64 : 72;
  final height = car ? 116 : 72;
  if (car) {
    paint.color = const Color(0x44202B38);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(12, 7, 42, 102),
        const Radius.circular(15),
      ),
      paint,
    );
    paint.color = const Color(0xFF242B37);
    for (final x in [7.0, 48.0]) {
      for (final y in [23.0, 78.0]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, 9, 19),
            const Radius.circular(3),
          ),
          paint,
        );
      }
    }
    paint.color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(13, 4, 38, 104),
        const Radius.circular(14),
      ),
      paint,
    );
    paint.color = const Color(0xFF333C48);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(17, 24, 30, 22),
        const Radius.circular(6),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(17, 75, 30, 17),
        const Radius.circular(5),
      ),
      paint,
    );
    paint.color = const Color(0xFFE7E9EE);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(18, 47, 28, 25),
        const Radius.circular(5),
      ),
      paint,
    );
  } else {
    paint.color = hiGoPurple.withValues(alpha: .14);
    canvas.drawCircle(const Offset(36, 36), 35, paint);
    paint.color = Colors.white;
    canvas.drawCircle(const Offset(36, 36), 25, paint);
    paint.color = hiGoPurple;
    canvas.drawCircle(const Offset(36, 36), 20, paint);
  }
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final bytes = (await image.toByteData(
    format: ui.ImageByteFormat.png,
  ))!.buffer.asUint8List();
  image.dispose();
  picture.dispose();
  return bytes;
}
