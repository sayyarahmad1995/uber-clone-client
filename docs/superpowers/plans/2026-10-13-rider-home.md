# Rider Home Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox syntax for tracking.

**Goal:** Deliver the approved rider home UI with a real Google Map, draggable destination panel, and local preview interactions.

**Architecture:** Add a rider feature alongside the existing auth pages. The page owns local presentation state; the map and destination panel remain separate widgets. Backend data and requests are deferred.

**Tech Stack:** Existing Flutter/Dart app, Material widgets, google_maps_flutter and its web implementation.

**Spec:** [Approved rider home design](../specs/2026-10-13-rider-home-design.md)

## Global Constraints
- Work in C:/Users/hbcc/Projects/uber-clone-frontend.
- Android and web are the verification targets; retain existing auth screens and upward transitions.
- Use Poppins, purple accents, navy text, and safe-area-aware controls.
- Three sheet positions: approximately 25%, 52%, and 88% of available height, adapted to short screens.
- Use real map tiles; sample cars and places remain clearly local demo data.
- Do not commit API keys or connect the Go server in this phase.
- Do not add live location permissions, fare requests, bookings, payments, or tracking.

## Review Focus
1. Dragging and scrolling the expanded list must not trap map gestures.
2. Short screens, keyboards, and larger text must keep actions reachable.
3. Missing map configuration must leave the sheet usable and explain the issue.
4. Google attribution and map controls must remain visible above overlays.
5. Demo login must not imply real authentication; local edits must not be represented as server persistence.

## File Structure
- lib/rider/rider_demo_data.dart: immutable sample places, coordinates, and cars.
- lib/rider/rider_home_page.dart: greeting, map/panel composition, navigation and local state.
- lib/rider/rider_map.dart: map camera, markers, insets and configuration/failure UI.
- lib/rider/destination_panel.dart: sheet content, shortcuts and recent-place tiles.
- lib/rider/destination_search_page.dart: local place search and selection.
- lib/rider/rider_preview_sheets.dart: address editing, scheduling and empty tab states.
- lib/app.dart and lib/pages/login_page.dart: route and local-demo entry.
- pubspec.yaml, android/app/build.gradle.kts, AndroidManifest.xml, web/index.html: map dependency and platform configuration.
- tool/prepare_web_maps.dart: inject a local web key into an ignored build copy, keeping tracked HTML key-free.
- test/rider_home_test.dart, test/rider_search_test.dart, existing test/app_test.dart: behavior and regression coverage.
- README.md and docs/maps-setup.md: run/setup instructions and demo boundaries.

### Task 1: Rider layout and draggable panel
**Interfaces:** RiderHomePage accepts an optional map builder for platform-independent widget tests. DestinationPanel receives a ScrollController plus callbacks for place/shortcut selection. RiderPlace contains id, name, address, latitude and longitude.
- [ ] Add failing widget tests for Home-selected navigation, all four shortcuts, recent places, and dragging between compact/default/expanded positions.
- [ ] Run flutter test test/rider_home_test.dart; confirm the new tests fail before implementation.
- [ ] Implement the local data, responsive map/panel stack, greeting, notification button, controls, and fixed bottom navigation. Use DraggableScrollableSheet with its supplied controller, LayoutBuilder for available height, and extent notifications for map insets. Avoid copying the mockup phone frame or system status bar.
- [ ] Add tests at 393x852 and 360x640 with 1.5 text scale: no overflow, panel content can scroll to recent places, and navigation remains reachable.
- [ ] Run the focused tests and commit the passing layout.

### Task 2: Real map and local configuration
**Interfaces:** RiderMap receives panel bottom inset, sample positions and selected destination, and exposes recenter through its controller. Coordinates initially center on F-8, Islamabad. The page's test map builder replaces native platform views in widget tests.
- [ ] Inspect the current Google Maps Flutter documentation, choose the compatible stable package version and record it in pubspec.lock.
- [ ] Add tests for unconfigured-map UI and retry, while confirming the draggable panel still works.
- [ ] Implement the GoogleMap surface and demo markers. Recenter returns to the sample location; do not label it as a detected GPS fix. Keep attribution above the panel using map padding and validate actual native rendering.
- [ ] Read the Android key from ignored local.properties via a manifest placeholder; add Android INTERNET permission. Align the Dart configured/unconfigured flag with the supplied key. Document key restriction to the Android application and signing certificate.
- [ ] Add a local preparation tool for web: use a web-specific restricted key supplied by environment/local configuration, inject it only into the ignored served build HTML, and load Maps JavaScript before Flutter starts. Never put the actual key in tracked HTML or logs.
- [ ] Show a clear state for missing configuration and a retry option if map initialization fails. Explain that SDK authorization errors may additionally require inspecting platform logs; do not claim every blank-tile condition is detectable from Dart.
- [ ] Verify focused widget tests; build Android/web and check live tiles with the user's configured keys before marking the map integration verified.
- [ ] Commit map integration and setup instructions without local key files.

### Task 3: Search, shortcuts, navigation and demo entry
**Interfaces:** DestinationSearchPage returns a RiderPlace through Navigator.pop. Address editing and scheduling return local values only. RiderHomePage owns those values for the current session.
- [ ] Add failing tests for case-insensitive search, empty results, selection/cancel, address validation, and schedule cancellation/past-time rejection.
- [ ] Implement local destination search, Home/Work address forms, Schedule date/time selection, and Airport selection. Choosing a destination updates local UI and map markers without a booking request.
- [ ] Implement notification and Activity/Wallet/Profile preview states with usable back navigation and explicit demo/empty copy.
- [ ] Add /rider route. On valid demo login, retain the existing no-authentication notice and offer a clear Continue to rider preview action. Preserve invalid-login validation and existing form tests.
- [ ] Verify back navigation does not lose the rider home session state; keyboard appearance must not hide search results or form actions.
- [ ] Run rider/search and existing app tests; commit passing local interactions.

### Task 4: Visual review and delivery
- [ ] Format lib/test/tool; run flutter analyze and the full flutter test suite. Resolve failures before continuing.
- [ ] Build Android debug and web. Inspect emulator and web at compact/default/expanded panel positions, including map attribution, drag behavior, map pan, shortcuts, search and keyboard.
- [ ] Compare the render with the supplied image: greeting/card proportions, white rounded panel, purple icons, recent-place spacing, and bottom navigation. Adjust responsive sizing while preserving the approved design.
- [ ] Review the complete diff for unintended auth changes, configuration leaks and unsupported claims; record any platform limitations.
- [ ] Update README and verification notes with actual results. Commit the final UI and provide screenshots and a concise completion report. Keep backend integration deferred.

## Prerequisite for live-map verification
The user has a Google Maps API key. Configure it locally during implementation; use separate platform-restricted keys where needed. The layout and widget tests can proceed before key setup, but live-map verification cannot be claimed without it.
