import 'package:higo_countrycode/rider/places_api.dart';
import 'package:higo_countrycode/rider/rider_demo_data.dart';

class FakePlaces implements PlacesRepository {
  @override
  Future<List<PlaceSuggestion>> search(
    String query,
    String session, {
    RiderPlace? bias,
  }) async => demoPlaces
      .where(
        (p) => '${p.name} ${p.address}'.toLowerCase().contains(
          query.toLowerCase(),
        ),
      )
      .map((p) => PlaceSuggestion(p.id, '${p.name}, ${p.address}'))
      .toList();
  @override
  Future<RiderPlace> details(
    PlaceSuggestion suggestion,
    String session,
  ) async => demoPlaces.firstWhere((p) => p.id == suggestion.id);
  @override
  Future<RiderPlace> reverse(double latitude, double longitude) async =>
      RiderPlace('map', 'Selected map location', '', latitude, longitude);
}
