import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../theme.dart';
import 'rider_demo_data.dart';

class DestinationPanel extends StatelessWidget {
  const DestinationPanel({
    super.key,
    required this.scrollController,
    required this.onSearch,
    required this.onPlace,
    required this.onShortcut,
    required this.onExpand,
    this.destination,
    this.homeAddress,
    this.workAddress,
    this.scheduleLabel,
  });
  final ScrollController scrollController;
  final VoidCallback onSearch, onExpand;
  final ValueChanged<RiderPlace> onPlace;
  final ValueChanged<String> onShortcut;
  final RiderPlace? destination;
  final String? homeAddress, workAddress, scheduleLabel;

  @override
  Widget build(BuildContext context) => PointerInterceptor(
    child: Material(
      key: const Key('destination-panel'),
      color: Colors.white,
      elevation: 12,
      shadowColor: hiGoNavy.withValues(alpha: .12),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      clipBehavior: Clip.antiAlias,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            ...ScrollConfiguration.of(context).dragDevices,
            PointerDeviceKind.mouse,
          },
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Semantics(
              label: 'Expand or collapse destination panel',
              button: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onExpand,
                child: SizedBox(
                  key: const Key('sheet-handle'),
                  height: 30,
                  child: Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC4C7D7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Text(
              'Where to?',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w700,
                letterSpacing: -.8,
              ),
            ),
            const SizedBox(height: 14),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                key: const Key('destination-search'),
                onTap: onSearch,
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F7FD),
                    border: Border.all(color: const Color(0xFFE0E2ED)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: hiGoPurple,
                        size: 27,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              destination?.name ?? 'Current location',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              destination?.address ?? demoPickup.address,
                              style: const TextStyle(
                                color: Color(0xFF8B91A6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 1,
                        height: 24,
                        color: const Color(0xFFD9DDEB),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.search_rounded, size: 25),
                    ],
                  ),
                ),
              ),
            ),
            if (destination != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 13,
                      color: Color(0xFF8B91A6),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Destination preview · No ride booked',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final twoRows =
                    MediaQuery.textScalerOf(context).scale(14) > 18 ||
                    constraints.maxWidth < 310;
                final width =
                    (constraints.maxWidth - (twoRows ? 10 : 30)) /
                    (twoRows ? 2 : 4);
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _Shortcut(
                      width: width,
                      id: 'home',
                      label: 'Home',
                      detail: homeAddress ?? 'Add address',
                      icon: Icons.home_rounded,
                      onTap: onShortcut,
                    ),
                    _Shortcut(
                      width: width,
                      id: 'work',
                      label: 'Work',
                      detail: workAddress ?? 'Add address',
                      icon: Icons.work_rounded,
                      onTap: onShortcut,
                    ),
                    _Shortcut(
                      width: width,
                      id: 'schedule',
                      label: 'Schedule',
                      detail: scheduleLabel ?? 'Plan a ride',
                      icon: Icons.event_available_rounded,
                      onTap: onShortcut,
                    ),
                    _Shortcut(
                      width: width,
                      id: 'airport',
                      label: 'Airport',
                      detail: 'ISB Airport',
                      icon: Icons.flight_takeoff_rounded,
                      onTap: onShortcut,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Recent Places',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: onSearch,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('See All'),
                      Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
                ),
              ],
            ),
            for (final place in demoPlaces.take(3)) ...[
              PlaceTile(place: place, onTap: () => onPlace(place)),
              if (place != demoPlaces[2])
                const Padding(
                  padding: EdgeInsets.only(left: 50),
                  child: Divider(height: 1, color: Color(0xFFF0F1F6)),
                ),
            ],
            const SizedBox(height: 10),
            const Text(
              'Sample places for your preview',
              style: TextStyle(fontSize: 11, color: Color(0xFF8B91A6)),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.width,
    required this.id,
    required this.label,
    required this.detail,
    required this.icon,
    required this.onTap,
  });
  final double width;
  final String id, label, detail;
  final IconData icon;
  final ValueChanged<String> onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Material(
      color: const Color(0xFFF6F7FD),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        key: Key('shortcut-$id'),
        borderRadius: BorderRadius.circular(14),
        onTap: () => onTap(id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: hiGoPurple, size: 27),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF8B91A6), fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class PlaceTile extends StatelessWidget {
  const PlaceTile({super.key, required this.place, required this.onTap});
  final RiderPlace place;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    minVerticalPadding: 10,
    leading: CircleAvatar(
      radius: 20,
      backgroundColor: const Color(0xFFF1F2F7),
      child: const Icon(
        Icons.history_rounded,
        color: Color(0xFF858BA1),
        size: 23,
      ),
    ),
    title: Text(
      place.name,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    ),
    subtitle: Text(
      place.address,
      style: const TextStyle(fontSize: 11, color: Color(0xFF8B91A6)),
    ),
    trailing: const Icon(Icons.chevron_right, color: Color(0xFF858BA1)),
    onTap: onTap,
  );
}
