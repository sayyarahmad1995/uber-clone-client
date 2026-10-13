import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:higo_countrycode/rider/rider_map.dart';
import 'package:higo_countrycode/theme.dart';

void main() {
  testWidgets(
    'missing key explains map setup and retry keeps controls available',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: hiGoTheme,
          home: const Scaffold(
            body: RiderMap(
              configured: false,
              bottomInset: 200,
              recenterRequest: 0,
            ),
          ),
        ),
      );
      expect(find.text('Your city, in view'), findsOneWidget);
      await tester.tap(find.text('Map setup'));
      await tester.pumpAndSettle();
      expect(find.textContaining('secretes.properties'), findsOneWidget);
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();
      expect(find.text('Map setup'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
