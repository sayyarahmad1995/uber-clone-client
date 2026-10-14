# Pickup and destination picker

The rider search screen supports independently editable pickup and destination, swapping, clearing, live autocomplete, session-local recent choices, and an exact map pin for either field. Free text must be resolved to a place or pin before continuing. No sample place list is used in the production picker.

## API connection

Default API: https://dev-api.higorides.com. Override with `--dart-define=HIGO_API_BASE_URL=...`.

- POST /v1/auth/login: identifier/password; access_token retained in memory only.
- POST /v1/places/autocomplete: input, selection session_token, optional current-device bias.
- GET /v1/places/{place_id}?session_token=...: canonical named-place coordinates.
- POST /v1/places/reverse-geocode: readable labels for exact map pins. Returned coordinates/Place IDs never replace a free pin.
- GET /v1/ride-services: select the first ordered available service for route-only preview.
- POST /v1/ride-previews: exact endpoints, optional Place IDs only for explicitly selected named places, service_code. Render server geometry and estimated driving time/distance; no invented fallback route or fare.

The existing authentication pages remain demo screens. The picker has a separate sign-in prompt for the development server. Use an existing verified rider account there. Refreshing the browser clears the in-memory session and recent selections. Passwords are not saved.

Device location is obtained only by the foreground geolocator API. If permission is denied or location times out, manual search and map selection remain usable. A map pin can be confirmed without an address if reverse geocoding fails.

## Local browser preview

The development API currently rejects browser CORS preflights. A loopback-only development server serves the web build and forwards an allowlisted set of API calls to that fixed HTTPS host. It does not change deployed CORS policy or log credentials. This is for local development, not production hosting.

```powershell
dart run tool/run_maps.dart web build --no-pub --no-web-resources-cdn --no-wasm-dry-run --dart-define=HIGO_API_BASE_URL=/api
dart run tool/serve_preview.dart 5175
```

Open http://127.0.0.1:5175/#/rider. Tap the location card, then Sign in for live place search. Native Android calls the API directly and does not need this bridge. Hosted web requires a same-origin proxy or configured server CORS.

Route preview ends at Done; ride request/driver matching is outside this change. Nearby cars and profile details on the existing home screen are still marked demo data.
