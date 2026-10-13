# Verification and implementation notes

Verified on 2026-10-13 with Flutter 3.44.4 and Dart 3.12.2.

- `flutter analyze --no-pub`: no issues found.
- `dart format lib test`: 15 files formatted.
- `flutter test --no-pub`: 19 tests passed, including vertical forward/back transitions and compact safe-area footer spacing.
- `flutter build web --no-pub --no-web-resources-cdn --no-wasm-dry-run`: successful; self-contained renderer resources included.
- Browser: inspected Home and Register at the mobile reference size; searched Pakistan in the package picker and confirmed PK / +92 selection; inspected Login navigation and layout.
- Additional 393 × 852 renders captured for Home, Register, Login, and the country sheet with the real image and bundled fonts loaded.
- One independent source review completed. Its validation-scroll and checkbox-accessibility findings were reproduced in failing tests, fixed, and verified against the green full suite. Its README delivery gap was resolved. No deferred findings.

## Decisions and tradeoffs

- Used a dedicated new repository at the user-selected folder on `feat/local-higo`, instead of a linked worktree, because no existing app was present there. If this needs relocation later, the independent checkout can be moved.
- Used a writable Flutter SDK/package-cache copy under this chat's `work` directory because permission to modify the shared installed cache was denied. This uses extra local disk space; the delivered app is a normal portable Flutter project and does not include that SDK copy.
- Tracked plan execution manually in a progress ledger because the skill's Bash bookkeeping scripts assumed a pre-existing Git repository and this host uses PowerShell. This requires maintaining the record by hand; verification above comes from actual tool output.
- Kept the new repository local with no merge or push because the request was for a local project and there is no base branch or configured remote. Remote integration can be decided separately.

Android debug APK built successfully and was installed on the Pixel 10 Pro API 37 emulator. Registration layout was visually checked there. Web was rebuilt successfully after the spacing and transition changes. iOS and Windows targets are included as source and have not been built. Authentication, password reset, OTP, and legal content remain explicitly marked local demos as agreed.

## Rider home UI (2026-10-13)

- Added real Google Maps, a responsive three-position draggable panel, local destination search, Home/Work address editing, schedule preview, demo tabs and login entry.
- `flutter test --no-pub`: 34 tests passed, including mouse/touch dragging, large text and keyboard layouts, destination state, address validation, schedule save/cancel/validation, key configuration and login entry.
- `flutter analyze --no-pub`: no issues found.
- Web production build succeeded with locally configured key. Real map tiles, sample location/cars, attribution visibility, calendar navigation and time selection were verified in the browser at phone size.
- Android Gradle build in the Codex sandbox was blocked because Java reports project/toolchain directories as not writable. The user built and ran the project from their own terminal; its debug APK was produced and the live map and draggable panel were visually checked on Pixel 10 Pro API 37.
- Independent whole-feature review found two web input issues: mouse dragging default and nested picker interception. Mouse failure was reproduced in a regression test, both fixes were applied, and the full green suite plus live calendar/time checks verified the fixes.
- Actual keys remain in ignored android/secretes.properties and generated web/maps-config.js; source delivery excludes both. No backend integration, GPS tracking or actual ride scheduling was added.

## Continuous map centering follow-up

- Map viewport changes now trigger post-layout, non-animated recentering on the preview user location, preserving the current zoom. Resize updates coalesce per frame and only one camera command is in flight; no delay timer was added.
- Native investigation found residual 42dp bottom padding biased Android's camera center upward while web ignored it. Removed that inset because the map viewport already ends above the sheet.
- Full suite: 36 tests passed. Analyzer: no issues. Web production build passed and live marker geometry matched the map center at both large and small sizes.
- Built the configured Android release successfully, installed it on the Pixel emulator, and visually verified the marker centered at normal, expanded and compact panel positions. The earlier manually built release lacked MAPS_CONFIGURED and was unsuitable for live-map verification; use the documented launcher for releases.
- Automatic review initially blocked finalizing while native behavior was unverified. Native discrepancy has now been investigated, corrected, and checked in the newly installed release.

## Follow-state behavior (2026-10-14)

- Panning away disables location following. Resizing the destination panel preserves the rider-chosen camera target and zoom; explicit recenter restores location following. Selecting a destination also preserves that destination view during resizing.
- App-issued camera commands and queued resize updates are excluded from user-pan detection.
- 39 tests passed; analyzer clean. Configured web and Android release builds succeeded.
- Browser check: manually panned map coordinates remained identical across sheet resizing, and the recenter button returned to F-8 before subsequent resizing.
- Android release installed and visually checked: panned Rawal Lake/Pakistan Colony area remained visible through expanded/compact sheet positions; recenter returned to F-8 and location remained centered on expansion.

## Android recenter animation

- Explicit recenter and destination camera actions use a 600 ms SDK animation. Resize updates remain immediate.
- Camera motion is guarded until idle, with a timeout for no-op updates; touching the map releases the guard for manual panning.
- 41 tests pass; analyzer reports no issues. Configured release APK built, installed and recenter endpoint checked on the Pixel emulator.


## Map controls follow-up

- Recenter animates target only, preserving zoom, bearing and tilt.
- North-Up animates bearing and tilt to zero while retaining camera target and zoom.
- 43 tests pass and analyzer is clean; configured Android and browser release builds succeed. Emulator zoom/pan/recenter check retained the zoom level; both UIs expose the new compass control.


## Standard Android build configuration

- GoogleMapsConfiguration in lib/configurations/google_maps.dart enables native maps by default. Android keys remain in the ignored properties file, read by Gradle.
- Web retains the setup helper and explicit configuration check. The optional MAPS_CONFIGURED build override remains supported.
- All 44 tests pass and analyzer reports no issues.

- Standard flutter build apk --release --no-pub succeeded without a Dart define or setup helper.

## Location field stretch animation

- Location field ink now paints on a local Material inside the scroll viewport, so its background participates in the same overscroll transform as its contents.
- Regression reproduced before the fix; all 45 tests pass afterward, analyzer is clean, Android and web release builds succeed.

