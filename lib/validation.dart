import 'package:phone_numbers_parser/phone_numbers_parser.dart';

String? validateName(String? value) =>
    value == null || value.trim().isEmpty ? 'Enter your full name.' : null;

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)
      ? null
      : 'Enter a valid email address.';
}

String? validatePassword(String? value) =>
    value == null || value.length < 8 ? 'Use at least 8 characters.' : null;

String? validateConfirmation(String? value, String password) =>
    value == password ? null : 'Passwords do not match.';

/// Normalizes valid numbers for the selected country; never verifies ownership.
String? internationalPhone(String input, String isoCode) {
  if (input.trim().isEmpty) return null;
  try {
    final selected = IsoCode.values.byName(isoCode.toUpperCase());
    final phone = PhoneNumber.parse(input, destinationCountry: selected);
    if (phone.isoCode != selected || !phone.isValid()) return null;
    return phone.international;
  } on Exception {
    return null;
  } on ArgumentError {
    return null;
  }
}
