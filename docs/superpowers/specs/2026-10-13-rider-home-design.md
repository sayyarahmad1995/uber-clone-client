# Rider home UI design

## Goal
Build the rider home screen in the existing Flutter app, using the supplied mockup as the visual reference. This phase covers UI and local interactions; the user's Go server is connected in a later phase.

## Layout
- Full-screen interactive Google Map, initially centered on F-8, Islamabad.
- Greeting/profile card at top left and notification button at top right, positioned within the system safe area.
- Purple current-location marker and clearly demo nearby-car markers at sample Islamabad positions.
- Recenter controls move above the panel as it expands.
- Rounded white draggable panel with a visible drag handle, Where to heading, current-location row, four shortcuts, and recent places.
- Fixed bottom navigation with Home selected; Activity, Wallet, and Profile show lightweight preview/empty states rather than inventing backend data.
- Retain Poppins, navy text, purple accents, pale shortcut cards, and existing upward page transitions.

## Panel behavior
Three snap positions: compact (about 25% of available height), default (about 52%), and expanded (about 88%). Final positions adapt to content, safe areas, and short screens. The panel's list scrolls after expansion; dragging over the map still pans the map. Google attribution remains visible above the sheet and navigation.

## Local interactions
Destination search opens a local search view containing sample recent places. Selecting a place updates the displayed destination without requesting a fare or booking. Home/Work open editable local address forms; Schedule opens date/time controls; Airport selects Islamabad airport. Notifications and other tabs show explicit empty/demo UI. Successful local demo login leads to rider home; no real authentication is implied.

## Map integration
Use the Google Maps Flutter package on Android and web. Configure platform-specific API keys outside tracked source. Do not commit actual keys. Initial Islamabad camera and sample position avoid requiring device location permission for the design preview. Live location permission and tracking are deferred. Map load/configuration failure displays a readable retry/configuration state while keeping the panel usable.

## Structure
Separate rider home layout, map surface, draggable destination panel, reusable shortcut/recent-place tiles, and local view state. Keep sample data in a replaceable frontend layer. Do not modify the Go server, add endpoints, or connect authentication, bookings, fares, payments, or driver tracking in this phase.

## Verification
Check sheet snapping and scrolling, bottom navigation, search selection, short-screen/larger-text layout, and existing auth flows. Visually review Android emulator and web with the map configured; verify attribution and controls at all panel positions.
