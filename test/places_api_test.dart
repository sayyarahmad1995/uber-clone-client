import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:higo_countrycode/rider/places_api.dart';
import 'package:higo_countrycode/rider/rider_demo_data.dart';
import 'package:higo_countrycode/rider/ride_route_preview.dart';
import 'package:higo_countrycode/rider/trip_locations.dart';

void main() {
  test(
    'authenticated search and details share the session and preserve canonical place ID',
    () async {
      final requests = <http.Request>[];
      final api = HiGoApi(
        client: MockClient((r) async {
          requests.add(r);
          if (r.url.path == '/v1/auth/login') {
            return http.Response('{"access_token":"test-session"}', 200);
          }
          expect(r.headers['Authorization'], 'Bearer test-session');
          if (r.url.path.endsWith('autocomplete')) {
            return http.Response(
              '{"suggestions":[{"place_id":"p1","label":"Mall, Islamabad"}]}',
              200,
            );
          }
          return http.Response(
            '{"place_id":"p1","label":"Mall, Islamabad","latitude":33.7,"longitude":73.0}',
            200,
          );
        }),
      );
      addTearDown(api.close);
      await api.signIn('test@example.com', 'test-only');
      final suggestions = await api.search(
        'Mall',
        'selection-session',
        bias: demoPickup,
      );
      final place = await api.details(suggestions.single, 'selection-session');
      expect(
        jsonDecode(requests[1].body)['session_token'],
        'selection-session',
      );
      expect(
        requests.last.url.queryParameters['session_token'],
        'selection-session',
      );
      expect(place.placeId, 'p1');
      expect(place.latitude, 33.7);
    },
  );
  test(
    'free pin reverse geocoding never changes coordinates or attaches routing place ID',
    () async {
      final api = HiGoApi(
        client: MockClient(
          (r) async => r.url.path.endsWith('login')
              ? http.Response('{"access_token":"test"}', 200)
              : http.Response(
                  '{"place_id":"nearby","label":"Nearby road","latitude":10.0,"longitude":20.0}',
                  200,
                ),
        ),
      );
      addTearDown(api.close);
      await api.signIn('test', 'test');
      final place = await api.reverse(33.72, 73.05);
      expect(place.latitude, 33.72);
      expect(place.longitude, 73.05);
      expect(place.placeId, isNull);
    },
  );
  test(
    '401 clears the session and requests sign-in without mock results',
    () async {
      final api = HiGoApi(
        client: MockClient(
          (r) async => r.url.path.endsWith('login')
              ? http.Response('{"access_token":"test"}', 200)
              : http.Response('', 401),
        ),
      );
      addTearDown(api.close);
      await api.signIn('test', 'test');
      await expectLater(
        api.search('Mall', 'session'),
        throwsA(
          isA<PlacesFailure>().having((e) => e.signInRequired, 'sign in', true),
        ),
      );
      expect(api.signedIn, false);
    },
  );
  test(
    'route uses catalog code and exact free pins rather than named routing IDs',
    () async {
      final api = HiGoApi(
        client: MockClient((r) async {
          if (r.url.path.endsWith('login')) {
            return http.Response('{"access_token":"test"}', 200);
          }
          if (r.url.path.endsWith('ride-services')) {
            return http.Response(
              '{"services":[{"code":"car","display_order":1}]}',
              200,
            );
          }
          final body = jsonDecode(r.body);
          expect(body['service_code'], 'car');
          expect(body['pickup'].containsKey('place_id'), false);
          expect(body['destination']['place_id'], 'named-place');
          return http.Response(
            jsonEncode({
              'route': {
                'distance_meters': 5200,
                'duration_seconds': 720,
                'encoded_polyline': '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
              },
            }),
            200,
          );
        }),
      );
      addTearDown(api.close);
      await api.signIn('test', 'test');
      final route = await api.preview(
        const TripLocations(
          pickup: demoPickup,
          destination: RiderPlace(
            'id',
            'Place',
            'Address',
            33.7,
            73.1,
            placeId: 'named-place',
          ),
        ),
      );
      expect(route.points.length, 3);
      expect(route.distanceMeters, 5200);
      expect(route.durationSeconds, 720);
    },
  );
  test('malformed road geometry is rejected', () {
    expect(
      () => RideRoutePreview.fromJson({
        'route': {
          'distance_meters': 1,
          'duration_seconds': 1,
          'encoded_polyline': '_',
        },
      }),
      throwsFormatException,
    );
  });
}
