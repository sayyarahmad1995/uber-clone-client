import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../configurations/google_maps.dart';
import '../theme.dart';
import '../widgets/auth_shell.dart';
import 'destination_search_page.dart';
import 'places_api.dart';
import 'places_sign_in.dart';
import 'ride_route_preview.dart';
import 'trip_locations.dart';

class RoutePreviewPage extends StatefulWidget {
  const RoutePreviewPage({
    super.key,
    required this.locations,
    required this.onEdit,
  });
  final TripLocations locations;
  final ValueChanged<TripLocations> onEdit;
  @override
  State<RoutePreviewPage> createState() => _RoutePreviewPageState();
}

class _RoutePreviewPageState extends State<RoutePreviewPage> {
  late TripLocations _locations = widget.locations;
  RideRoutePreview? _route;
  PlacesFailure? _error;
  GoogleMapController? _map;
  bool _loading = true;
  int _revision = 0;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _map?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final revision = ++_revision;
    setState(() {
      _loading = true;
      _error = null;
      _route = null;
    });
    try {
      final route = await HiGoApi.shared.preview(_locations);
      if (!mounted || revision != _revision) return;
      setState(() => _route = route);
      await _fit();
    } on PlacesFailure catch (e) {
      if (mounted && revision == _revision) setState(() => _error = e);
    } finally {
      if (mounted && revision == _revision) setState(() => _loading = false);
    }
  }

  Future<void> _fit() async {
    final points =
        _route?.points ??
        [
          LatLng(_locations.pickup.latitude, _locations.pickup.longitude),
          LatLng(
            _locations.destination.latitude,
            _locations.destination.longitude,
          ),
        ];
    final south = points.map((p) => p.latitude).reduce(math.min),
        north = points.map((p) => p.latitude).reduce(math.max);
    final west = points.map((p) => p.longitude).reduce(math.min),
        east = points.map((p) => p.longitude).reduce(math.max);
    try {
      await _map?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(south, west),
            northeast: LatLng(north, east),
          ),
          48,
        ),
      );
    } catch (_) {
      /* map can be disposed during navigation */
    }
  }

  Future<void> _edit(bool pickup) async {
    final updated = await Navigator.push<TripLocations>(
      context,
      MaterialPageRoute(
        builder: (_) => DestinationSearchPage(
          initialPickup: _locations.pickup,
          initialDestination: _locations.destination,
          editPickup: pickup,
        ),
      ),
    );
    if (updated == null || !mounted) return;
    setState(() => _locations = updated);
    widget.onEdit(updated);
    _load();
  }

  Future<void> _signIn() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => PlacesSignInDialog(api: HiGoApi.shared),
    );
    if (ok == true && mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final mapAvailable =
        GoogleMapsConfiguration.mapsEnabled &&
        (kIsWeb || defaultTargetPlatform == TargetPlatform.android);
    return Scaffold(
      backgroundColor: Colors.white,
      body: MobileFrame(
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  const BackButton(),
                  const Text(
                    'Review route',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Expanded(
                child: mapAvailable
                    ? GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            _locations.pickup.latitude,
                            _locations.pickup.longitude,
                          ),
                          zoom: 13,
                        ),
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        webCameraControlEnabled: false,
                        markers: {
                          Marker(
                            markerId: const MarkerId('pickup'),
                            position: LatLng(
                              _locations.pickup.latitude,
                              _locations.pickup.longitude,
                            ),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueViolet,
                            ),
                          ),
                          Marker(
                            markerId: const MarkerId('destination'),
                            position: LatLng(
                              _locations.destination.latitude,
                              _locations.destination.longitude,
                            ),
                          ),
                        },
                        polylines: {
                          if (_route != null)
                            Polyline(
                              polylineId: const PolylineId('route'),
                              points: _route!.points,
                              color: hiGoPurple,
                              width: 5,
                            ),
                        },
                        onMapCreated: (controller) {
                          _map = controller;
                          _fit();
                        },
                      )
                    : const Center(child: Text('Map is unavailable')),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCCD0DE),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Trip details',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.circle,
                          color: hiGoPurple,
                          size: 14,
                        ),
                        title: const Text('Pickup'),
                        subtitle: Text(_locations.pickup.name),
                        trailing: TextButton(
                          onPressed: () => _edit(true),
                          child: const Text('Change'),
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                        ),
                        title: const Text('Destination'),
                        subtitle: Text(_locations.destination.name),
                        trailing: TextButton(
                          onPressed: () => _edit(false),
                          child: const Text('Change'),
                        ),
                      ),
                      if (_loading) const LinearProgressIndicator(),
                      if (_error != null) ...[
                        Text(_error!.message),
                        TextButton(
                          onPressed: _error!.signInRequired ? _signIn : _load,
                          child: Text(
                            _error!.signInRequired ? 'Sign in' : 'Retry route',
                          ),
                        ),
                      ],
                      if (_route != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              '${(_route!.durationSeconds / 60).ceil()} min\nest. time',
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              '${(_route!.distanceMeters / 1000).toStringAsFixed(1)} km\nest. distance',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
