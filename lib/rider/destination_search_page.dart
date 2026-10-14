import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/auth_shell.dart';
import 'current_location.dart';
import 'location_map_picker.dart';
import 'places_api.dart';
import 'places_sign_in.dart';
import 'rider_demo_data.dart';
import 'trip_locations.dart';

class DestinationSearchPage extends StatefulWidget {
  const DestinationSearchPage({
    super.key,
    this.initialPickup,
    this.initialQuery = '',
    this.initialDestination,
    this.editPickup = false,
    this.recentPlaces = const [],
    this.repository,
    this.currentLocationLoader = loadCurrentLocation,
    this.mapBuilder,
  });
  final RiderPlace? initialPickup, initialDestination;
  final String initialQuery;
  final bool editPickup;
  final List<RiderPlace> recentPlaces;
  final PlacesRepository? repository;
  final CurrentLocationLoader currentLocationLoader;
  final LocationMapBuilder? mapBuilder;
  @override
  State<DestinationSearchPage> createState() => _DestinationSearchPageState();
}

class _DestinationSearchPageState extends State<DestinationSearchPage> {
  late final PlacesRepository _api = widget.repository ?? HiGoApi.shared;
  final _pickupText = TextEditingController(),
      _destinationText = TextEditingController();
  final _pickupFocus = FocusNode(), _destinationFocus = FocusNode();
  RiderPlace? _pickup, _destination, _deviceLocation;
  late bool _editingPickup;
  Timer? _debounce;
  int _revision = 0;
  bool _loading = false, _locating = false;
  PlacesFailure? _failure;
  List<PlaceSuggestion> _results = [];
  String _pickupSession = _newSession(), _destinationSession = _newSession();
  static String _newSession() => List.generate(
    16,
    (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  String get _session => _editingPickup ? _pickupSession : _destinationSession;
  TextEditingController get _text =>
      _editingPickup ? _pickupText : _destinationText;
  String get _query => _text.text.trim();
  RiderPlace? get _selected => _editingPickup ? _pickup : _destination;
  bool get _valid =>
      _pickup != null &&
      _destination != null &&
      (_pickup!.latitude != _destination!.latitude ||
          _pickup!.longitude != _destination!.longitude);
  @override
  void initState() {
    super.initState();
    _pickup = widget.initialPickup;
    _destination = widget.initialDestination;
    _pickupText.text = _pickup?.name ?? '';
    _destinationText.text = _destination?.name ?? widget.initialQuery;
    _editingPickup = widget.editPickup;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _queueSearch();
    });
    _pickupFocus.addListener(() {
      if (_pickupFocus.hasFocus) _activate(true);
    });
    _destinationFocus.addListener(() {
      if (_destinationFocus.hasFocus) _activate(false);
    });
  }

  void _activate(bool pickup) {
    if (_editingPickup == pickup) return;
    _debounce?.cancel();
    _revision++;
    setState(() {
      _editingPickup = pickup;
      _results = [];
      _failure = null;
      _loading = false;
    });
    if (_selected == null) _queueSearch();
  }

  void _changed(bool pickup) {
    _editingPickup = pickup;
    _revision++;
    setState(() {
      if (pickup) {
        _pickup = null;
      } else {
        _destination = null;
      }
      _failure = null;
      _results = [];
      _loading = false;
    });
    _queueSearch();
  }

  void _queueSearch() {
    _debounce?.cancel();
    if (_query.length < 2 || _selected != null) return;
    final revision = _revision;
    final query = _query, session = _session;
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted || revision != _revision) return;
      setState(() => _loading = true);
      try {
        final results = await _api.search(
          query,
          session,
          bias: _deviceLocation,
        );
        if (mounted && revision == _revision) {
          setState(() => _results = results);
        }
      } on PlacesFailure catch (e) {
        if (mounted && revision == _revision) setState(() => _failure = e);
      } catch (_) {
        if (mounted && revision == _revision) {
          setState(
            () => _failure = const PlacesFailure(
              'Search could not load. Please try again.',
            ),
          );
        }
      } finally {
        if (mounted && revision == _revision) setState(() => _loading = false);
      }
    });
  }

  void _assign(RiderPlace place, bool pickup) {
    _debounce?.cancel();
    _revision++;
    setState(() {
      if (pickup) {
        _pickup = place;
        _pickupText.text = place.name;
        _pickupSession = _newSession();
      } else {
        _destination = place;
        _destinationText.text = place.name;
        _destinationSession = _newSession();
      }
      _results = [];
      _failure = null;
      _loading = false;
    });
    if (pickup && _destination == null) {
      _destinationFocus.requestFocus();
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _select(PlaceSuggestion suggestion) async {
    final pickup = _editingPickup, revision = ++_revision, session = _session;
    _debounce?.cancel();
    setState(() {
      _loading = true;
      _failure = null;
    });
    try {
      final place = await _api.details(suggestion, session);
      if (mounted && revision == _revision) _assign(place, pickup);
    } on PlacesFailure catch (e) {
      if (mounted && revision == _revision) setState(() => _failure = e);
    } catch (_) {
      if (mounted && revision == _revision) {
        setState(
          () => _failure = const PlacesFailure(
            'Could not load this place. Try again.',
          ),
        );
      }
    } finally {
      if (mounted && revision == _revision) setState(() => _loading = false);
    }
  }

  Future<void> _currentLocation() async {
    final pickup = _editingPickup, revision = ++_revision;
    _debounce?.cancel();
    setState(() {
      _locating = true;
      _failure = null;
      _loading = false;
    });
    try {
      final point = await widget.currentLocationLoader();
      if (mounted && revision == _revision) {
        _deviceLocation = point;
        _assign(point, pickup);
      }
    } on LocationFailure catch (e) {
      if (mounted && revision == _revision) {
        setState(() => _failure = PlacesFailure(e.message));
      }
    } catch (_) {
      if (mounted && revision == _revision) {
        setState(
          () => _failure = const PlacesFailure(
            'Location unavailable. Search or choose on map.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _chooseOnMap() async {
    final pickup = _editingPickup;
    _debounce?.cancel();
    _revision++;
    setState(() => _loading = false);
    FocusScope.of(context).unfocus();
    final point = await Navigator.push<RiderPlace>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationMapPicker(
          pickup: pickup,
          initial: _selected ?? _deviceLocation ?? _pickup ?? demoPickup,
          mapBuilder: widget.mapBuilder,
          repository: _api,
        ),
      ),
    );
    if (point != null && mounted) _assign(point, pickup);
  }

  Future<void> _signIn() async {
    final api = _api;
    if (api is! HiGoApi) return;
    FocusScope.of(context).unfocus();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => PlacesSignInDialog(api: api),
    );
    if (ok == true && mounted) {
      setState(() => _failure = null);
      _queueSearch();
    }
  }

  void _swap() {
    _debounce?.cancel();
    _revision++;
    setState(() {
      final old = _pickup;
      _pickup = _destination;
      _destination = old;
      _pickupText.text = _pickup?.name ?? '';
      _destinationText.text = _destination?.name ?? '';
      _pickupSession = _newSession();
      _destinationSession = _newSession();
      _results = [];
      _failure = null;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _pickupText.dispose();
    _destinationText.dispose();
    _pickupFocus.dispose();
    _destinationFocus.dispose();
    super.dispose();
  }

  Widget _field(bool pickup) {
    final active = _editingPickup == pickup;
    final controller = pickup ? _pickupText : _destinationText;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      constraints: const BoxConstraints(minHeight: 82),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFAF9FF) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active ? hiGoPurple : const Color(0xFFD9DCE8),
          width: active ? 1.5 : 1.2,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Icon(
              pickup ? Icons.circle : Icons.location_on_rounded,
              color: hiGoPurple,
              size: pickup ? 12 : 25,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pickup ? 'Pickup location' : 'Destination',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF858BA1),
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    key: Key(pickup ? 'pickup-query' : 'place-query'),
                    controller: controller,
                    focusNode: pickup ? _pickupFocus : _destinationFocus,
                    autofocus: pickup == widget.editPickup,
                    onTap: () => _activate(pickup),
                    onChanged: (_) => _changed(pickup),
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(fontSize: 17, color: hiGoNavy),
                    decoration: InputDecoration(
                      hintText: pickup ? 'Search pickup' : 'Search destination',
                      hintStyle: const TextStyle(color: Color(0xFFA1A6BA)),
                      isDense: true,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              tooltip: pickup ? 'Clear pickup' : 'Clear destination',
              icon: const Icon(
                Icons.cancel_rounded,
                size: 20,
                color: Color(0xFFADB1C4),
              ),
              onPressed: () {
                controller.clear();
                (pickup ? _pickupFocus : _destinationFocus).requestFocus();
                _changed(pickup);
              },
            )
          else
            const SizedBox(width: 12),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recent = _query.isEmpty || _selected != null;
    final signedOut = _api is HiGoApi && !(_api).signedIn;
    return Scaffold(
      backgroundColor: Colors.white,
      body: MobileFrame(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 20, 24),
                child: Row(
                  children: [
                    const BackButton(),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Where to?',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  key: const Key('location-search-scroll'),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _field(true),
                              SizedBox(
                                height: 14,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 21),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: List.generate(
                                        3,
                                        (_) => Container(
                                          width: 2,
                                          height: 2,
                                          color: const Color(0xFFCFD0DE),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              _field(false),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton.filledTonal(
                          tooltip: 'Swap pickup and destination',
                          onPressed: _locating ? null : _swap,
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFF2EFFF),
                            foregroundColor: hiGoPurple,
                          ),
                          icon: const Icon(Icons.swap_vert_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Material(
                      color: const Color(0xFFF3F0FF),
                      borderRadius: BorderRadius.circular(18),
                      child: ListTile(
                        key: const Key('choose-on-map'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        leading: const Icon(
                          Icons.map_outlined,
                          color: hiGoPurple,
                          size: 29,
                        ),
                        title: const Text(
                          'Choose on map',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Select ${_editingPickup ? 'pickup' : 'destination'} on map',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8580AB),
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: hiGoPurple,
                        ),
                        onTap: _chooseOnMap,
                      ),
                    ),
                    ListTile(
                      key: const Key('use-current-location'),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      leading: const Icon(
                        Icons.my_location_rounded,
                        color: hiGoPurple,
                      ),
                      title: Text(
                        _locating
                            ? 'Finding your location…'
                            : 'Use current location',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: _locating ? null : _currentLocation,
                    ),
                    if (_failure != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          _failure!.message,
                          style: const TextStyle(
                            color: Color(0xFF9A3845),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    if (signedOut || (_failure?.signInRequired ?? false))
                      Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7FB),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Find your next stop',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Sign in to search places and preview your route.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF858BA1),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: _signIn,
                              icon: const Icon(Icons.login_rounded, size: 18),
                              label: const Text(
                                'Sign in for live place search',
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: LinearProgressIndicator(),
                      ),
                    if (!recent &&
                        !_loading &&
                        _failure == null &&
                        _query.length >= 2 &&
                        _results.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('No matching places'),
                      ),
                    if (recent && widget.recentPlaces.isEmpty && !signedOut)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'Search for a place or choose it on the map.',
                          style: TextStyle(
                            color: Color(0xFF858BA1),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    if (recent)
                      for (final place in widget.recentPlaces)
                        _tile(
                          place.name,
                          place.address,
                          Icons.history_rounded,
                          () => _assign(place, _editingPickup),
                        ),
                    if (!recent)
                      for (final place in _results)
                        _tile(
                          place.label.split(',').first,
                          place.label.contains(',')
                              ? place.label
                                    .substring(place.label.indexOf(',') + 1)
                                    .trim()
                              : '',
                          Icons.location_on_outlined,
                          () => _select(place),
                        ),
                    if (!recent && _results.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Powered by Google',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF858BA1),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              if (_pickup != null || _destination != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const Key('confirm-locations'),
                      onPressed: _valid && !_loading && !_locating
                          ? () => Navigator.pop(
                              context,
                              TripLocations(
                                pickup: _pickup!,
                                destination: _destination!,
                              ),
                            )
                          : null,
                      child: const Text('Continue'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) => Column(
    children: [
      const Divider(height: 1, color: Color(0xFFEEEFF5)),
      ListTile(
        contentPadding: EdgeInsets.zero,
        minVerticalPadding: 14,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF2F3F8),
          child: Icon(icon, color: const Color(0xFF858BA1)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: subtitle.isEmpty
            ? null
            : Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: Color(0xFF959BB0)),
              ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF858BA1)),
        onTap: _loading ? null : onTap,
      ),
    ],
  );
}
