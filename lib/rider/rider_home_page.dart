import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/auth_shell.dart';
import 'destination_panel.dart';
import 'rider_demo_data.dart';
import 'rider_map.dart';
import 'destination_search_page.dart';
import 'rider_preview_sheets.dart';
import 'trip_locations.dart';
import 'places_api.dart';
import 'route_preview_page.dart';

typedef RiderMapBuilder =
    Widget Function(
      BuildContext context,
      double bottomInset,
      RiderPlace? destination,
      int recenterRequest,
    );

class RiderHomePage extends StatefulWidget {
  const RiderHomePage({
    super.key,
    this.mapBuilder,
    this.placesRepository,
    this.recentPlaces = const [],
  });
  final RiderMapBuilder? mapBuilder;
  final PlacesRepository? placesRepository;
  final List<RiderPlace> recentPlaces;
  @override
  State<RiderHomePage> createState() => _RiderHomePageState();
}

class _RiderHomePageState extends State<RiderHomePage> {
  final _sheet = DraggableScrollableController();
  ScrollController? _panelScroll;
  double _extent = .52;
  int _tab = 0, _recenterRequest = 0;
  int _northUpRequest = 0;
  RiderPlace? _destination, _pickup;
  late final List<RiderPlace> _recentPlaces = [...widget.recentPlaces];
  String? _homeAddress, _workAddress;
  DateTime? _schedule;
  @override
  void dispose() {
    _sheet.dispose();
    super.dispose();
  }

  void _expand() => _sheet.animateTo(
    _extent > .7 ? .25 : .88,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOutCubic,
  );
  Future<void> _search({bool pickup = false, String query = ''}) async {
    final locations = await Navigator.push<TripLocations>(
      context,
      MaterialPageRoute(
        builder: (_) => DestinationSearchPage(
          repository: widget.placesRepository,
          initialPickup: _pickup,
          initialQuery: query,
          initialDestination: _destination,
          editPickup: pickup,
          recentPlaces: _recentPlaces,
        ),
      ),
    );
    if (locations == null || !mounted) return;
    setState(() {
      _pickup = locations.pickup;
      _destination = locations.destination;
      for (final place in [locations.pickup, locations.destination]) {
        _recentPlaces.removeWhere((entry) => entry.id == place.id);
        _recentPlaces.insert(0, place);
      }
      if (_recentPlaces.length > 10) {
        _recentPlaces.removeRange(10, _recentPlaces.length);
      }
    });
    _select(locations.destination);
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => RoutePreviewPage(
          locations: locations,
          onEdit: (updated) => setState(() {
            _pickup = updated.pickup;
            _destination = updated.destination;
          }),
        ),
      ),
    );
  }

  void _select(RiderPlace place) {
    setState(() => _destination = place);
    if (_panelScroll?.hasClients ?? false) _panelScroll!.jumpTo(0);
    if (_sheet.isAttached) {
      _sheet.animateTo(
        .52,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _shortcut(String id) async {
    if (id == 'airport') {
      await _search(query: 'Islamabad International Airport');
      return;
    }
    if (id == 'schedule') {
      final value = await chooseSchedule(context, _schedule);
      if (value != null && mounted) setState(() => _schedule = value);
      return;
    }
    final value = await editSavedAddress(
      context,
      id == 'home' ? 'Home' : 'Work',
      id == 'home' ? _homeAddress : _workAddress,
    );
    if (value != null && mounted) {
      setState(() {
        if (id == 'home') {
          _homeAddress = value;
        } else {
          _workAddress = value;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: MobileFrame(
      child: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    children: [
                      const Positioned.fill(
                        child: ColoredBox(color: Color(0xFFE1EEE9)),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: constraints.maxHeight * _extent + 4,
                        child:
                            widget.mapBuilder?.call(
                              context,
                              0,
                              _destination,
                              _recenterRequest,
                            ) ??
                            RiderMap(
                              bottomInset: 0,
                              destination: _destination,
                              recenterRequest: _recenterRequest,
                              northUpRequest: _northUpRequest,
                              pickup: _pickup,
                            ),
                      ),
                      if (_extent < .76)
                        Positioned(
                          top: MediaQuery.paddingOf(context).top + 16,
                          left: 16,
                          right: 16,
                          child: PointerInterceptor(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Material(
                                    color: Colors.white.withValues(alpha: .96),
                                    borderRadius: BorderRadius.circular(20),
                                    elevation: 2,
                                    shadowColor: hiGoNavy.withValues(
                                      alpha: .08,
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () => setState(() => _tab = 3),
                                      child: Padding(
                                        padding: const EdgeInsets.all(13),
                                        child: Row(
                                          children: [
                                            const CircleAvatar(
                                              radius: 23,
                                              backgroundColor: Color(
                                                0xFFEFEDFF,
                                              ),
                                              child: Icon(
                                                Icons.person_rounded,
                                                color: Color(0xFF9294AC),
                                                size: 30,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _greeting(),
                                                    style: const TextStyle(
                                                      color: Color(0xFF8B91A6),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const Text(
                                                    'Ahsan',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  elevation: 2,
                                  shadowColor: hiGoNavy.withValues(alpha: .08),
                                  child: IconButton(
                                    tooltip: 'Notifications',
                                    padding: const EdgeInsets.all(16),
                                    onPressed: () =>
                                        showRiderNotifications(context),
                                    icon: const Badge(
                                      smallSize: 7,
                                      backgroundColor: hiGoPurple,
                                      child: Icon(
                                        Icons.notifications_none_rounded,
                                        size: 27,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_extent < .76)
                        Positioned(
                          right: 16,
                          bottom: constraints.maxHeight * _extent + 22,
                          child: Column(
                            children: [
                              _MapButton(
                                label: 'North-Up: reset rotation and tilt',
                                icon: Icons.explore_outlined,
                                onTap: () => setState(() => _northUpRequest++),
                              ),
                              const SizedBox(height: 10),
                              _MapButton(
                                label: 'Recenter on F-8 preview location',
                                icon: Icons.my_location_rounded,
                                onTap: () => setState(() => _recenterRequest++),
                              ),
                              const SizedBox(height: 10),
                              _MapButton(
                                label: 'Explore destination',
                                icon: Icons.near_me_outlined,
                                onTap: _search,
                              ),
                            ],
                          ),
                        ),
                      NotificationListener<DraggableScrollableNotification>(
                        onNotification: (notice) {
                          if ((_extent - notice.extent).abs() > .001) {
                            setState(() => _extent = notice.extent);
                          }
                          return false;
                        },
                        child: DraggableScrollableSheet(
                          controller: _sheet,
                          minChildSize: .25,
                          initialChildSize: .52,
                          maxChildSize: .88,
                          snap: true,
                          snapSizes: const [.25, .52, .88],
                          builder: (context, scrollController) {
                            _panelScroll = scrollController;
                            return DestinationPanel(
                              scrollController: scrollController,
                              destination: _destination,
                              pickup: _pickup,
                              onPickup: () => _search(pickup: true),
                              recentPlaces: _recentPlaces,
                              homeAddress: _homeAddress,
                              workAddress: _workAddress,
                              scheduleLabel: _schedule == null
                                  ? null
                                  : '${MaterialLocalizations.of(context).formatShortMonthDay(_schedule!)} · ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(_schedule!))}',
                              onExpand: _expand,
                              onSearch: _search,
                              onPlace: _select,
                              onShortcut: _shortcut,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const _PreviewTab(
                  icon: Icons.receipt_long_outlined,
                  title: 'Your journeys start here',
                  subtitle:
                      'Your ride history will appear here once rides are connected.',
                ),
                const _PreviewTab(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Your wallet, ready when you are',
                  subtitle:
                      'Payment methods and balances will be available when payments are connected.',
                ),
                const _PreviewTab(
                  icon: Icons.person_outline_rounded,
                  title: 'Your rider profile',
                  subtitle:
                      'Ahsan · Local UI preview\nProfile details are sample data.',
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE9EBF2))),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  for (var i = 0; i < 4; i++)
                    Expanded(
                      child: _NavItem(
                        index: i,
                        selected: _tab == i,
                        onTap: () => setState(() => _tab = i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  String _greeting() {
    final hour = DateTime.now().hour;
    return hour < 12
        ? 'Good Morning,'
        : hour < 17
        ? 'Good Afternoon,'
        : 'Good Evening,';
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => PointerInterceptor(
    child: Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: hiGoNavy.withValues(alpha: .12),
      child: IconButton(
        tooltip: label,
        onPressed: onTap,
        padding: const EdgeInsets.all(13),
        icon: Icon(icon, size: 25),
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.selected,
    required this.onTap,
  });
  final int index;
  final bool selected;
  final VoidCallback onTap;
  static const labels = ['Home', 'Activity', 'Wallet', 'Profile'];
  static const icons = [
    Icons.home_rounded,
    Icons.receipt_long_outlined,
    Icons.account_balance_wallet_outlined,
    Icons.person_outline_rounded,
  ];
  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    child: InkWell(
      key: Key('nav-${labels[index].toLowerCase()}'),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icons[index],
              color: selected ? hiGoPurple : const Color(0xFF8B91A6),
              size: 25,
            ),
            const SizedBox(height: 2),
            Text(
              labels[index],
              style: TextStyle(
                fontSize: 11,
                color: selected ? hiGoPurple : const Color(0xFF8B91A6),
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 2,
              width: 28,
              decoration: BoxDecoration(
                color: selected ? hiGoPurple : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PreviewTab extends StatelessWidget {
  const _PreviewTab({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: const Color(0xFFF0EEFF),
              child: Icon(icon, color: hiGoPurple, size: 38),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF8B91A6)),
            ),
            const SizedBox(height: 20),
            const Text(
              'UI preview',
              style: TextStyle(color: hiGoPurple, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    ),
  );
}
