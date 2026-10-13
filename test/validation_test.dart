import 'package:flutter_test/flutter_test.dart';
import 'package:higo_countrycode/validation.dart';

void main() {
  test('required name rejects whitespace and accepts a trimmed name', () {
    expect(validateName('  '), isNotNull);
    expect(validateName(null), isNotNull);
    expect(validateName('  Ayesha Khan  '), isNull);
  });
  test('email rejects missing domain and accepts surrounding whitespace', () {
    expect(validateEmail('person@'), isNotNull);
    expect(validateEmail(''), isNotNull);
    expect(validateEmail(' person@example.com '), isNull);
  });
  test('password minimum and confirmation preserve literal password text', () {
    expect(validatePassword('short'), isNotNull);
    expect(validatePassword('Example8!'), isNull);
    expect(validateConfirmation('Example8', 'Example8!'), isNotNull);
    expect(validateConfirmation(' Example8!', 'Example8!'), isNotNull);
    expect(validateConfirmation('Example8!', 'Example8!'), isNull);
  });
  test('national trunk zero and international paste produce the same E164', () {
    expect(internationalPhone('020 7946 0018', 'GB'), '+442079460018');
    expect(internationalPhone('+44 20 7946 0018', 'GB'), '+442079460018');
    expect(internationalPhone('0300 1234567', 'PK'), '+923001234567');
  });
  test(
    'shared dial codes retain valid country-specific phone interpretation',
    () {
      expect(internationalPhone('2025550119', 'US'), '+12025550119');
      expect(internationalPhone('4165550123', 'CA'), '+14165550123');
    },
  );
  test('empty malformed and country-mismatched numbers are rejected', () {
    expect(internationalPhone('', 'US'), isNull);
    expect(internationalPhone('123', 'PK'), isNull);
    expect(internationalPhone('not a phone', 'US'), isNull);
    expect(internationalPhone('+44 20 7946 0018', 'PK'), isNull);
    expect(internationalPhone('2025550119', 'ZZ'), isNull);
  });
}
