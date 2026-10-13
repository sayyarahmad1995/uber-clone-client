import 'package:flutter_test/flutter_test.dart';
import 'package:higo_countrycode/configurations/google_maps.dart';

void main() {
  test('native maps are enabled without a build flag', () {
    expect(GoogleMapsConfiguration.mapsEnabled, isTrue);
  });
}
