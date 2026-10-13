import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:higo_countrycode/rider/rider_home_page.dart';
import 'package:higo_countrycode/theme.dart';

Future<void> openRider(
  WidgetTester tester, {
  Size size = const Size(393, 852),
  double scale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: hiGoTheme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: RiderHomePage(
        mapBuilder: (_, _, _, _) => const ColoredBox(color: Color(0xFFE6EFEB)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('desktop mouse dragging expands the destination panel', (
    tester,
  ) async {
    await openRider(tester);
    final before = tester
        .getTopLeft(find.byKey(const Key('destination-panel')))
        .dy;
    await tester.drag(
      find.byKey(const Key('sheet-handle')),
      const Offset(0, -250),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.byKey(const Key('destination-panel'))).dy,
      lessThan(before - 100),
    );
  });
  testWidgets(
    'sheet expands to reach recent places and collapses to reveal the map',
    (tester) async {
      await openRider(tester);
      expect(find.text('Where to?'), findsOneWidget);
      expect(find.text('Add address'), findsNWidgets(2));
      final initialTop = tester
          .getTopLeft(find.byKey(const Key('destination-panel')))
          .dy;
      await tester.drag(
        find.byKey(const Key('sheet-handle')),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.byKey(const Key('destination-panel'))).dy,
        lessThan(initialTop - 100),
      );
      await tester.scrollUntilVisible(
        find.text('Islamabad International Airport'),
        180,
        scrollable: find.descendant(
          of: find.byKey(const Key('destination-panel')),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Islamabad International Airport').hitTestable(),
        findsOneWidget,
      );
      await tester.drag(
        find.byKey(const Key('sheet-handle')),
        const Offset(0, 700),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.byKey(const Key('destination-panel'))).dy,
        greaterThan(initialTop + 100),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'short screen and large text keep panel content and navigation reachable',
    (tester) async {
      await openRider(tester, size: const Size(360, 640), scale: 1.5);
      await tester.drag(
        find.byKey(const Key('sheet-handle')),
        const Offset(0, -450),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Islamabad International Airport'),
        180,
        scrollable: find.descendant(
          of: find.byKey(const Key('destination-panel')),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Islamabad International Airport').hitTestable(),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('nav-profile')).hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('returning from a preview tab retains the home panel', (
    tester,
  ) async {
    await openRider(tester);
    await tester.tap(find.byKey(const Key('nav-wallet')));
    await tester.pumpAndSettle();
    expect(find.text('Your wallet, ready when you are'), findsOneWidget);
    await tester.tap(find.byKey(const Key('nav-home')));
    await tester.pumpAndSettle();
    expect(find.text('Where to?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
