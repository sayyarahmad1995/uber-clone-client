import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:higo_countrycode/app.dart';

void main() {
  testWidgets(
    'registration enters upward without horizontal movement and returns downward',
    (tester) async {
      tester.view.physicalSize = const Size(412, 940);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const HiGoApp());
      await tester.tap(find.text('Get Started'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final duringPush = tester.getTopLeft(find.text('Create Your Account'));
      await tester.pumpAndSettle();
      final settled = tester.getTopLeft(find.text('Create Your Account'));
      expect(duringPush.dx, closeTo(settled.dx, .01));
      expect(duringPush.dy, greaterThan(settled.dy + 40));
      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final duringPop = tester.getTopLeft(find.text('Create Your Account'));
      expect(duringPop.dx, closeTo(settled.dx, .01));
      expect(duringPop.dy, greaterThan(settled.dy + 40));
      await tester.pumpAndSettle();
      expect(find.text('Welcome to HiGO'), findsOneWidget);
    },
  );

  for (final destination in [
    ('Get Started', 'to-login'),
    ('Log In', 'to-register'),
  ]) {
    testWidgets(
      '${destination.$2} footer stays close to Android safe bottom on tall screens',
      (tester) async {
        tester.view.physicalSize = const Size(412, 1200);
        tester.view.devicePixelRatio = 1;
        tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
        addTearDown(tester.view.reset);
        await tester.pumpWidget(const HiGoApp());
        await tester.ensureVisible(find.text(destination.$1));
        await tester.tap(find.text(destination.$1));
        await tester.pumpAndSettle();
        final footer = find.byKey(Key(destination.$2));
        final bottomGap = 1200 - 24 - tester.getBottomLeft(footer).dy;
        expect(bottomGap, inInclusiveRange(0, 12));
        expect(tester.takeException(), isNull);
      },
    );
  }
}
