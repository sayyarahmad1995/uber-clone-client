# HiGO Rides — local Flutter app

Home, Login, and Register recreated from the existing FlutterFlow screens, with the original background photo, bundled Poppins typography, and a searchable package-based country picker.

## Run

Requires Flutter 3.44.4 or newer with Dart 3.12.2 or newer. Open this folder in Android Studio or VS Code, select your Flutter SDK, then run:

```powershell
flutter pub get
flutter run -d chrome
```

For Android, start an emulator or connect a device, then use `flutter run`. Windows and iOS source targets are included; their native toolchains are required. Web and Android debug builds were verified, with registration checked in the Android emulator.

## Country and phone behavior

- `country_picker` supplies the full searchable country list, flags, ISO codes, and dialing codes. No country table or manually configured dropdown options are used.
- The initial selection follows the device locale's country, with US fallback when absent or unsupported. Selection is always editable.
- Search by country name, ISO code, or dialing code. Country identity is stored separately from the dial code, so US and Canada remain distinct even though both use +1.
- `phone_numbers_parser` handles national prefixes and international formatting. A valid local number is normalized to E.164. If a pasted international number belongs to a different country, select that country first.
- Validation checks metadata and format; it does not verify ownership, reachability, or SMS delivery.

## Local demo scope

Registration requires a name, valid phone, email, password of at least 8 characters, matching confirmation, and terms acceptance. Login accepts an email or an international phone number including +country code, plus a password. Successful forms display a demo confirmation. Password visibility can be toggled without changing entered text.

No accounts are created, no credentials are saved, and no authentication or SMS request is made. Password reset, OTP, Terms of Service, and Privacy Policy open notices explaining that the services/content are not configured. Terms acceptance is a form demonstration, not acceptance of an actual configured legal agreement.

## Verify and build

```powershell
flutter analyze
flutter test
flutter build web --no-web-resources-cdn --no-wasm-dry-run
```

Serve `build/web` from an HTTP server. For example, with Python installed:

```powershell
python -m http.server 5173 --bind 127.0.0.1 --directory build/web
```

Then open http://127.0.0.1:5173. The web bundle includes its renderer resources, image, and fonts for local serving.

## Structure

- `lib/pages/`: the three screens.
- `lib/widgets/country_phone_field.dart`: reusable controlled country/phone widget.
- `lib/widgets/auth_shell.dart`: shared responsive photo/form shell.
- `lib/widgets/labeled_field.dart`: reusable labeled inputs and password controls.
- `lib/validation.dart`: field validation and phone normalization.
- `test/`: navigation, form, small-screen, accessibility, picker, and parsing tests.
- `docs/`: approved design and implementation plan.

## Assets and dependencies

The background is the original `Gemini_Generated_Image_zh2im2zh2im2zh2i.png` already used in the user's FlutterFlow project, copied from the user's Downloads. It is not a replacement or newly generated image. Poppins is from Google Fonts under the SIL Open Font License; the license is included in `assets/fonts/OFL.txt`. Noto Color Emoji is from googlefonts/noto-emoji under the SIL Open Font License; its license is included in `assets/fonts/NotoEmoji-LICENSE.txt`.

Packages and resolved versions are recorded in `pubspec.lock`. `country_picker` and `phone_numbers_parser` are MIT licensed. `cupertino_icons` provides font resources referenced by the picker. Flutter's runtime license registry also includes dependency licenses.

Visual differences from FlutterFlow: obvious spelling errors are corrected; the previously empty phone selector now shows a flag and dial code; the forms scroll when space is constrained, including with larger text and keyboards. Pages slide up when opened and down when returning. Footer spacing is 8 logical pixels plus the system safe area; surplus height goes into the photo header. A centered mobile-width layout is used on wide windows. Platform launch icons remain Flutter's generated defaults.

## Rider home preview

The rider screen adds a real Google Map, three-position draggable destination panel, local sample-place search, editable Home/Work shortcuts, schedule preview, and Home/Activity/Wallet/Profile navigation. Complete valid demo login and choose **Continue to rider preview**, or launch with "--route=/rider".

Configure maps through the ignored **android/secretes.properties** file; see [map setup](docs/maps-setup.md) for commands. The Go backend remains unconnected. Saved addresses and schedules last only for this app session; they are UI previews and do not create rides.
