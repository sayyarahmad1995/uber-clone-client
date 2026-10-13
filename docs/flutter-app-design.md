# Local HiGO Flutter app

## Agreed scope
Create the project at `C:\Users\hbcc\Projects\flutter-project-countrycode`. Recreate the existing FlutterFlow Home, Login, and Register screens, with working navigation, local form validation, and a country picker using the Flutter `country_picker` package. Authentication is a UI demonstration at this stage; no backend, account creation, or SMS is included.

## UI and navigation
Use the existing screens as the visual reference: Poppins typography, purple primary buttons, photo backgrounds with blue/purple overlays, rounded white form panels, and pale bordered input fields. Inspect Login and the existing image assets before implementation. Preserve page structure and visible content, correcting obvious spelling errors. Match the 393 × 852 mobile reference and keep the forms scrollable for small screens and keyboards. Center a constrained mobile-width experience on wider windows.

Home links to Register through Get Started and to Login through Log In. Login and Register link to each other. Forms retain their inputs while the user opens and closes the country picker. Password fields have visibility toggles. Any unconnected authentication or password-reset action clearly identifies itself as a local demo.

## Country and phone selection
Use `country_picker` from pub.dev, selected explicitly by the user. Do not create a country database, download a dataset into the app, or manually configure country dropdown options. Show a flag and dial code beside the national phone input. Tapping the selector opens a searchable country sheet supplied by the package. Store both ISO alpha-2 country code and dialing code, including countries that share a calling code. Choose a default from the device locale when it provides a supported country, otherwise show a deterministic US fallback. The user can always change it.

Derive the international phone representation from the chosen dialing code and national number without repeating the dial code. For validation and national-prefix handling, use a maintained phone-number parsing package if required; do not claim that length-only checks verify an actual number or that a number can receive SMS.

## Form behavior
Registration requires name, phone, email, password, matching confirmation, and terms acceptance. Login validates its visible identifier and password fields. Show errors near the relevant fields. Valid submissions show a demo confirmation, without storing passwords or creating an account. Do not invent legal documents; terms and privacy affordances identify that legal content is not configured.

## Structure and dependencies
Keep app theme, pages, reusable form controls, country/phone control, and validation logic in separate focused files. Bundle fonts and available reference images as assets so ordinary page rendering does not rely on a font or image network request. Use Flutter's standard navigation and form mechanisms. Keep dependencies limited to the country picker and any phone validation dependency justified by the implementation.

## Validation and delivery
Write tests for meaningful validation behavior, international phone formatting, country selection/search and shared calling codes, and navigation. Run Flutter analysis and tests, then run the app locally and inspect the three screens and picker at the mobile reference size. Document any visual differences caused by unavailable original assets. Deliver the source project, concise run instructions, and a runnable local preview when the installed tooling supports it.

## Review status
Approved by the user on 2026-10-13 and implemented locally. See VERIFICATION.md for delivery evidence.

