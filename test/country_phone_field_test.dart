import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:higo_countrycode/widgets/country_phone_field.dart';

void main() {
  test(
    'device country is honored and absent or unsupported country falls back',
    () {
      expect(initialCountry(const Locale('en', 'GB')).countryCode, 'GB');
      expect(initialCountry(const Locale('en')).countryCode, 'US');
      expect(initialCountry(const Locale('en', 'ZZ')).countryCode, 'US');
    },
  );

  for (final selection in [('Canada', 'CA', '1'), ('Pakistan', 'PK', '92')]) {
    testWidgets(
      'search and select ${selection.$1} preserves ISO and dial code',
      (tester) async {
        final controller = TextEditingController(text: '2025550119');
        addTearDown(controller.dispose);
        Country? result;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CountryPhoneField(
                controller: controller,
                country: Country.parse('US'),
                onCountryChanged: (value) => result = value,
              ),
            ),
          ),
        );
        await tester.tap(find.byKey(const Key('country-selector')));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).last, selection.$1);
        await tester.pumpAndSettle();
        await tester.tap(find.text(selection.$1).last);
        await tester.pumpAndSettle();
        expect(result?.countryCode, selection.$2);
        expect(result?.phoneCode, selection.$3);
        expect(controller.text, '2025550119');
      },
    );
  }

  testWidgets('cancelling picker does not change country or entered phone', (
    tester,
  ) async {
    final controller = TextEditingController(text: '03001234567');
    addTearDown(controller.dispose);
    var callbacks = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CountryPhoneField(
            controller: controller,
            country: Country.parse('PK'),
            onCountryChanged: (_) => callbacks++,
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('country-selector')));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(callbacks, 0);
    expect(controller.text, '03001234567');
    expect(find.text('+92'), findsOneWidget);
  });
}
