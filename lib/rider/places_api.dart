import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'rider_demo_data.dart';
import 'trip_locations.dart';
import 'ride_route_preview.dart';

class PlacesFailure implements Exception {
  const PlacesFailure(this.message, {this.signInRequired = false});
  final String message;
  final bool signInRequired;
}

class PlaceSuggestion {
  const PlaceSuggestion(this.id, this.label);
  final String id, label;
}

abstract class PlacesRepository {
  Future<List<PlaceSuggestion>> search(
    String query,
    String session, {
    RiderPlace? bias,
  });
  Future<RiderPlace> details(PlaceSuggestion suggestion, String session);
  Future<RiderPlace> reverse(double latitude, double longitude);
}

class HiGoApi implements PlacesRepository {
  HiGoApi({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _base =
          baseUrl ??
          const String.fromEnvironment(
            'HIGO_API_BASE_URL',
            defaultValue: 'https://dev-api.higorides.com',
          );
  static final shared = HiGoApi();
  final http.Client _client;
  final String _base;
  String? _token;
  bool get signedIn => _token != null;

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    if (authenticated && _token == null) {
      throw const PlacesFailure(
        'Sign in to search live places.',
        signInRequired: true,
      );
    }
    try {
      final request = http.Request(method, Uri.parse('$_base$path'));
      request.headers['Content-Type'] = 'application/json';
      if (authenticated) request.headers['Authorization'] = 'Bearer $_token';
      if (body != null) request.body = jsonEncode(body);
      final response = await _client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 401) {
        if (authenticated) _token = null;
        throw PlacesFailure(
          authenticated
              ? 'Your session expired. Sign in again.'
              : 'Check your account and password, then try again.',
          signInRequired: authenticated,
        );
      }
      if (response.statusCode == 403) {
        throw const PlacesFailure(
          'A verified rider account is required to search places.',
        );
      }
      if (response.statusCode == 429) {
        throw const PlacesFailure(
          'Too many searches. Wait a moment and try again.',
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const PlacesFailure(
          'The location service is unavailable. Please try again.',
        );
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on PlacesFailure {
      rethrow;
    } catch (_) {
      throw const PlacesFailure(
        'Could not connect. Check your connection and try again.',
      );
    }
  }

  Future<void> signIn(String identifier, String password) async {
    final data = await _request(
      'POST',
      '/v1/auth/login',
      body: {'identifier': identifier.trim(), 'password': password},
      authenticated: false,
    );
    final token = data['access_token'];
    if (token is! String || token.isEmpty) {
      throw const PlacesFailure(
        'Sign-in did not return a session. Please try again.',
      );
    }
    _token = token;
  }

  @override
  Future<List<PlaceSuggestion>> search(
    String query,
    String session, {
    RiderPlace? bias,
  }) async {
    final data = await _request(
      'POST',
      '/v1/places/autocomplete',
      body: {
        'input': query,
        'session_token': session,
        if (bias != null)
          'bias': {'latitude': bias.latitude, 'longitude': bias.longitude},
      },
    );
    return (data['suggestions'] as List)
        .map(
          (item) => PlaceSuggestion(
            item['place_id'] as String,
            item['label'] as String,
          ),
        )
        .toList();
  }

  RiderPlace _place(Map<String, dynamic> data, {bool namedPlace = false}) {
    final lat = (data['latitude'] as num).toDouble();
    final lng = (data['longitude'] as num).toDouble();
    if (!lat.isFinite || !lng.isFinite || lat.abs() > 90 || lng.abs() > 180) {
      throw const PlacesFailure(
        'This place has invalid coordinates. Try another location.',
      );
    }
    final label = (data['label'] as String?)?.trim();
    return RiderPlace(
      data['place_id'] as String? ?? 'point-$lat-$lng',
      label == null || label.isEmpty ? 'Selected map location' : label,
      '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
      lat,
      lng,
      placeId: namedPlace ? data['place_id'] as String? : null,
    );
  }

  @override
  Future<RiderPlace> details(
    PlaceSuggestion suggestion,
    String session,
  ) async => _place(
    await _request(
      'GET',
      '/v1/places/${Uri.encodeComponent(suggestion.id)}?session_token=${Uri.encodeQueryComponent(session)}',
    ),
    namedPlace: true,
  );
  @override
  Future<RiderPlace> reverse(double latitude, double longitude) async {
    final place = _place(
      await _request(
        'POST',
        '/v1/places/reverse-geocode',
        body: {'latitude': latitude, 'longitude': longitude},
      ),
    );
    // A readable address must never move a user's explicitly selected point.
    return RiderPlace(place.id, place.name, place.address, latitude, longitude);
  }

  Future<RideRoutePreview> preview(TripLocations locations) async {
    final catalog = await _request('GET', '/v1/ride-services');
    final services = List<Map<String, dynamic>>.from(
      catalog['services'] as List,
    );
    services.sort(
      (a, b) => ((a['display_order'] as num?) ?? 0).compareTo(
        (b['display_order'] as num?) ?? 0,
      ),
    );
    if (services.isEmpty) {
      throw const PlacesFailure('No ride services are currently available.');
    }
    Map<String, dynamic> endpoint(RiderPlace place) => {
      'latitude': place.latitude,
      'longitude': place.longitude,
      if (place.placeId != null) 'place_id': place.placeId,
    };
    final data = await _request(
      'POST',
      '/v1/ride-previews',
      body: {
        'pickup': endpoint(locations.pickup),
        'destination': endpoint(locations.destination),
        'service_code': services.first['code'],
      },
    );
    try {
      return RideRoutePreview.fromJson(data);
    } catch (_) {
      throw const PlacesFailure(
        'The route could not be displayed. Please try again.',
      );
    }
  }

  void close() => _client.close();
}
