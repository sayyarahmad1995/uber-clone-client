import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:higo_countrycode/app.dart';

Future<void> openRegister(WidgetTester tester) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(const HiGoApp());
  await tester.ensureVisible(find.text('Get Started'));
  await tester.tap(find.text('Get Started'));
  await tester.pumpAndSettle();
}

Future<void> revealAndTap(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.clearAllTestValues();
  });

  testWidgets('home connects registration and login and the forms cross-link', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    await openRegister(tester);
    expect(find.text('Create Your Account'), findsOneWidget);
    await revealAndTap(tester, find.byKey(const Key('to-login')));
    expect(find.text('Welcome Back'), findsOneWidget);
    await revealAndTap(tester, find.byKey(const Key('to-register')));
    expect(find.text('Create Your Account'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  });

  testWidgets(
    'registration validates required fields, phone and confirmation before demo',
    (tester) async {
      addTearDown(tester.view.reset);
      await openRegister(tester);
      await revealAndTap(tester, find.byKey(const Key('submit-register')));
      expect(find.text('Enter your full name.'), findsOneWidget);
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(
        find.text('Enter a valid phone number for the selected country.'),
        findsOneWidget,
      );
      expect(find.text('Please accept the terms to continue.'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('full-name')), 'Ayesha Khan');
      await tester.enterText(
        find.byKey(const Key('email')),
        'ayesha@example.com',
      );
      await tester.enterText(find.byKey(const Key('password')), 'Example8!');
      await tester.enterText(
        find.byKey(const Key('confirm-password')),
        'different',
      );
      await tester.enterText(
        find.byKey(const Key('phone-number')),
        '2025550119',
      );
      await revealAndTap(tester, find.byKey(const Key('submit-register')));
      expect(find.text('Passwords do not match.'), findsOneWidget);
      expect(find.text('Registration demo'), findsNothing);
      await tester.enterText(
        find.byKey(const Key('confirm-password')),
        'Example8!',
      );
      await revealAndTap(tester, find.byKey(const Key('terms-checkbox')));
      await revealAndTap(tester, find.byKey(const Key('submit-register')));
      expect(find.text('Registration demo'), findsOneWidget);
      expect(find.textContaining('+12025550119'), findsOneWidget);
    },
  );

  testWidgets(
    'password visibility and picker dismissal retain registration input',
    (tester) async {
      addTearDown(tester.view.reset);
      await openRegister(tester);
      await tester.enterText(find.byKey(const Key('password')), 'Example8!');
      await revealAndTap(tester, find.byKey(const Key('password-visibility')));
      final password = tester.widget<TextFormField>(
        find.byKey(const Key('password')),
      );
      final editor = tester.widget<EditableText>(
        find.descendant(
          of: find.byKey(const Key('password')),
          matching: find.byType(EditableText),
        ),
      );
      expect(editor.obscureText, isFalse);
      expect(password.controller!.text, 'Example8!');
      await revealAndTap(tester, find.byKey(const Key('country-selector')));
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('password')))
            .controller!
            .text,
        'Example8!',
      );
    },
  );

  testWidgets(
    'short screens with keyboard and larger text can reach submit without overflow',
    (tester) async {
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      await openRegister(tester);
      tester.view.physicalSize = const Size(320, 640);
      tester.view.viewInsets = const FakeViewPadding(bottom: 240);
      await tester.pumpAndSettle();
      await revealAndTap(tester, find.byKey(const Key('submit-register')));
      expect(tester.takeException(), isNull);
      expect(find.text('Enter your full name.'), findsOneWidget);
      expect(
        tester.getTopLeft(find.byKey(const Key('full-name'))).dy,
        greaterThanOrEqualTo(0),
      );
      expect(
        tester.getBottomLeft(find.byKey(const Key('full-name'))).dy,
        lessThan(400),
      );
    },
  );

  testWidgets(
    'required terms checkbox identifies its purpose to screen readers',
    (tester) async {
      addTearDown(tester.view.reset);
      final semantics = tester.ensureSemantics();
      await openRegister(tester);
      await tester.ensureVisible(find.byKey(const Key('terms-checkbox')));
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel(
          'Accept HiGO Terms of Service and acknowledge Privacy Policy',
        ),
        findsOneWidget,
      );
      semantics.dispose();
    },
  );

  testWidgets('login rejects invalid email and confirms valid local demo', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(const HiGoApp());
    await revealAndTap(tester, find.byKey(const Key('home-login')));
    await revealAndTap(tester, find.byKey(const Key('submit-login')));
    expect(
      find.text('Enter a valid email address or phone with country code.'),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const Key('email')),
      'ayesha@example.com',
    );
    await tester.enterText(find.byKey(const Key('password')), 'Example8!');
    await revealAndTap(tester, find.byKey(const Key('submit-login')));
    expect(find.text('Login demo'), findsOneWidget);
    await tester.tap(find.byKey(const Key('enter-rider-preview')));
    await tester.pumpAndSettle();
    expect(find.text('Where to?'), findsOneWidget);
    expect(find.byKey(const Key('nav-home')), findsOneWidget);
  });
}
