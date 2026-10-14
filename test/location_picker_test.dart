import 'dart:async';
import 'fake_places.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:higo_countrycode/rider/current_location.dart';
import 'package:higo_countrycode/rider/destination_search_page.dart';
import 'package:higo_countrycode/rider/location_map_picker.dart';
import 'package:higo_countrycode/rider/rider_demo_data.dart';
import 'package:higo_countrycode/rider/trip_locations.dart';
import 'package:higo_countrycode/theme.dart';

void main() {
  testWidgets(
    'pickup and destination can be independently selected and swapped',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: hiGoTheme,
          home: DestinationSearchPage(
            initialPickup: demoPickup,
            repository: FakePlaces(),
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('pickup-query')));
      await tester.enterText(find.byKey(const Key('pickup-query')), 'mosque');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Faisal Mosque'));
      await tester.tap(find.text('Faisal Mosque'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('place-query')), 'safa');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Safa Gold Mall'));
      await tester.tap(find.text('Safa Gold Mall'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Swap pickup and destination'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('pickup-query')))
            .controller!
            .text,
        'Safa Gold Mall',
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('place-query')))
            .controller!
            .text,
        'Faisal Mosque',
      );
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('confirm-locations')))
            .onPressed,
        isNotNull,
      );
      await tester.enterText(
        find.byKey(const Key('place-query')),
        'unselected text',
      );
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('confirm-locations')))
            .onPressed,
        isNull,
      );
    },
  );
  testWidgets('location denial leaves manual choices available', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: hiGoTheme,
        home: DestinationSearchPage(
          repository: FakePlaces(),
          currentLocationLoader: () async => throw const LocationFailure(
            'Permission denied. Choose on map instead.',
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('use-current-location')));
    await tester.pumpAndSettle();
    expect(
      find.text('Permission denied. Choose on map instead.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('choose-on-map')), findsOneWidget);
  });
  testWidgets('late location result does not overwrite a newer edit', (
    tester,
  ) async {
    final pending = Completer<RiderPlace>();
    await tester.pumpWidget(
      MaterialApp(
        theme: hiGoTheme,
        home: DestinationSearchPage(
          repository: FakePlaces(),
          currentLocationLoader: () => pending.future,
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('use-current-location')));
    await tester.pump();
    await tester.enterText(
      find.byKey(const Key('place-query')),
      'my newer search',
    );
    pending.complete(demoPlaces[0]);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('place-query')))
          .controller!
          .text,
      'my newer search',
    );
  });
  testWidgets('map confirmation returns the moved coordinates', (tester) async {
    RiderPlace? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await Navigator.push<RiderPlace>(
                context,
                MaterialPageRoute(
                  builder: (_) => LocationMapPicker(
                    pickup: true,
                    initial: demoPickup,
                    mapBuilder: (context, initial, move, ready) => TextButton(
                      onPressed: () {
                        ready();
                        move(const LatLng(33.72, 73.05));
                      },
                      child: const Text('Move test map'),
                    ),
                  ),
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('confirm-map-location')))
          .onPressed,
      isNull,
    );
    expect(
      tester.getSize(find.widgetWithText(TextButton, 'Move test map')).width,
      greaterThan(350),
    );
    await tester.tap(find.text('Move test map'));
    await tester.pump();
    await tester.tap(find.text('Confirm pickup'));
    await tester.pumpAndSettle();
    expect(result!.latitude, 33.72);
    expect(result!.longitude, 73.05);
  });
  testWidgets(
    'confirm returns both locations and cancellation returns no edits',
    (tester) async {
      TripLocations? result;
      await tester.pumpWidget(
        MaterialApp(
          theme: hiGoTheme,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await Navigator.push<TripLocations>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DestinationSearchPage(
                      initialPickup: demoPickup,
                      initialDestination: demoPlaces[0],
                      repository: FakePlaces(),
                    ),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm-locations')));
      await tester.pumpAndSettle();
      expect(result!.pickup, demoPickup);
      expect(result!.destination, demoPlaces[0]);
    },
  );
}
