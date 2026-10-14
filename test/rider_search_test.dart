import 'package:flutter/material.dart';
import 'fake_places.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:higo_countrycode/rider/destination_search_page.dart';
import 'package:higo_countrycode/rider/rider_preview_sheets.dart';
import 'package:higo_countrycode/theme.dart';
import 'rider_home_test.dart' show openRider;

void main() {
  testWidgets(
    'search remains usable with keyboard and larger text on a short screen',
    (tester) async {
      await openRider(tester, size: const Size(360, 640), scale: 1.5);
      await tester.tap(find.byKey(const Key('destination-search')));
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 240);
      await tester.enterText(find.byKey(const Key('place-query')), 'safa');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Safa Gold Mall'),
        160,
        scrollable: find
            .descendant(
              of: find.byKey(const Key('location-search-scroll')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Safa Gold Mall').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      tester.view.viewInsets = const FakeViewPadding();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Choose your pickup'), findsOneWidget);
    },
  );
  testWidgets('saving a future schedule updates only the local shortcut', (
    tester,
  ) async {
    await openRider(tester);
    await tester.ensureVisible(find.byKey(const Key('shortcut-schedule')));
    await tester.tap(find.byKey(const Key('shortcut-schedule')));
    await tester.pumpAndSettle();
    expect(find.textContaining('No ride will be scheduled'), findsOneWidget);
    await tester.tap(find.text('Save schedule'));
    await tester.pumpAndSettle();
    expect(find.text('Plan a ride'), findsNothing);
    expect(find.byKey(const Key('shortcut-schedule')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('search ignores case and reports empty results', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: hiGoTheme,
        home: DestinationSearchPage(repository: FakePlaces()),
      ),
    );
    await tester.enterText(find.byKey(const Key('place-query')), 'SAFA');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Safa Gold Mall'), findsOneWidget);
    expect(find.text('Centaurus Mall'), findsNothing);
    await tester.enterText(find.byKey(const Key('place-query')), 'not a place');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('No matching places'), findsOneWidget);
  });
  testWidgets(
    'selecting a destination keeps pickup editable before continuing',
    (tester) async {
      await openRider(tester);
      await tester.tap(find.byKey(const Key('destination-search')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('place-query')), 'safa');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Safa Gold Mall'),
        160,
        scrollable: find
            .descendant(
              of: find.byKey(const Key('location-search-scroll')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.text('Safa Gold Mall'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('pickup-query')), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('place-query')))
            .controller!
            .text,
        'Safa Gold Mall',
      );
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('confirm-locations')))
            .onPressed,
        isNull,
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Choose your pickup'), findsOneWidget);
    },
  );
  testWidgets(
    'address validation prevents empty values and local edits remain visible',
    (tester) async {
      await openRider(tester);
      await tester.ensureVisible(find.byKey(const Key('shortcut-home')));
      await tester.tap(find.byKey(const Key('shortcut-home')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save address'));
      await tester.pumpAndSettle();
      expect(find.text('Enter an address.'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('saved-address')),
        'House 12, F-8',
      );
      await tester.tap(find.text('Save address'));
      await tester.pumpAndSettle();
      expect(find.text('House 12, F-8'), findsOneWidget);
    },
  );
  test('schedule rejects now/past and accepts future local times', () {
    final now = DateTime(2026, 10, 13, 18);
    expect(validateSchedule(now, now), isNotNull);
    expect(validateSchedule(DateTime(2026, 10, 13, 17), now), isNotNull);
    expect(validateSchedule(DateTime(2026, 10, 13, 19), now), isNull);
  });
  testWidgets('cancelling a schedule leaves the shortcut unchanged', (
    tester,
  ) async {
    await openRider(tester);
    await tester.ensureVisible(find.byKey(const Key('shortcut-schedule')));
    await tester.tap(find.byKey(const Key('shortcut-schedule')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Plan a ride'), findsOneWidget);
  });
  testWidgets(
    'airport shortcut searches live places rather than selecting sample coordinates',
    (tester) async {
      await openRider(tester);
      await tester.ensureVisible(find.byKey(const Key('shortcut-airport')));
      await tester.tap(find.byKey(const Key('shortcut-airport')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('place-query')))
            .controller!
            .text,
        'Islamabad International Airport',
      );
      expect(find.byKey(const Key('pickup-query')), findsOneWidget);
    },
  );
}
