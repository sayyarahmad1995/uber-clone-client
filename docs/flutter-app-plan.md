# Local HiGO Flutter App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Recreate Home, Login, and Register locally with working navigation, validated demo forms, and the package-based country picker.

**Architecture:** A small Flutter app with shared theme and form controls, three pages, and a reusable country/phone field. Country metadata and search come from `country_picker`; phone parsing uses `phone_numbers_parser`. Original images and Poppins fonts are bundled where accessible.

**Tech Stack:** Flutter, Dart, `country_picker`, `phone_numbers_parser`, `flutter_test`.

**Spec:** [Approved design](flutter-app-design.md).

**Project root:** `C:\Users\hbcc\Projects\flutter-project-countrycode`.

## Global constraints

- Recreate the existing FlutterFlow Home, Login, and Register screens.
- Authentication is a UI demonstration at this stage; no backend, account creation, or SMS is included.
- Use `country_picker` from pub.dev, selected explicitly by the user.
- Do not create a country database, download a dataset into the app, or manually configure country dropdown options.
- Match the 393 × 852 mobile reference and keep the forms scrollable for small screens and keyboards.
- Store both ISO alpha-2 country code and dialing code, including countries that share a calling code.
- Choose a default from the device locale when it provides a supported country, otherwise show a deterministic US fallback.
- Do not store passwords or invent legal documents. Valid submissions identify themselves as local demos.

## Review focus

1. Shared calling codes: selecting Canada instead of the US preserves the distinct ISO country even though both use +1.
2. National phone prefixes and pasted international numbers: normalize through the phone parser, without duplicating the selected prefix.
3. Picker cancellation and search: closing without selecting retains the number and country; search accepts country name, ISO code, and dial code where supported by the package.
4. Short screens, keyboard, and larger text: forms scroll to errors and submit controls without overflow.
5. Unsupported or missing locale country: fall back to US consistently and allow manual selection.

## File structure

- `lib/main.dart`: application entry point.
- `lib/app.dart`: theme configuration and Home/Login/Register routes.
- `lib/theme.dart`: colors, Poppins typography, inputs, and buttons.
- `lib/pages/home_page.dart`: welcome screen.
- `lib/pages/login_page.dart`: login demo and validation.
- `lib/pages/register_page.dart`: registration demo and validation.
- `lib/widgets/auth_shell.dart`: photo header, gradient, responsive width, scrolling form panel.
- `lib/widgets/labeled_field.dart`: reusable labeled inputs and password visibility.
- `lib/widgets/country_phone_field.dart`: country selector and national phone input.
- `lib/validation.dart`: pure validation and international phone formatting.
- `assets/images/`, `assets/fonts/`: reference imagery and bundled Poppins font files.
- `test/validation_test.dart`, `test/country_phone_field_test.dart`, `test/app_test.dart`: behavior tests.
- `README.md`: prerequisites, run commands, demo boundaries, asset differences, dependency licenses.

## Task 1: Establish the local project and validated phone model

**Files:** `pubspec.yaml`, `lib/validation.dart`, `test/validation_test.dart`, generated platform files.

**Interfaces:** Produce `String? validateName(String?)`, `String? validateEmail(String?)`, `String? validatePassword(String?)`, `String? validateConfirmation(String?, String password)`, and `String? internationalPhone(String input, String isoCode)`. A null international-phone result means parsing or validation failed. Validators return null when valid and a user-facing message otherwise.

- [ ] Inspect applicable `AGENTS.md` instructions and the target directory; preserve any existing files. Check Flutter version and supported devices, and resolve the earlier startup delay before scaffolding.
- [ ] Inspect Login and recover the original background image sources from visible FlutterFlow properties. Record reference typography, dimensions, and spacing. Download only assets needed for the approved recreation, keeping credentials out of output.
- [ ] Create a Flutter project named `higo_countrycode` at the requested root with Android, iOS, web, and Windows source targets. Resolve compatible stable package versions and retain the lockfile. Initialize a dedicated Git repository only if the target is not already in a repository.
- [ ] Write `validation_test.dart` before the production validation functions. Assert empty/whitespace names fail, trimmed names pass, malformed emails fail, valid emails pass, passwords shorter than 8 characters fail, and mismatched confirmation fails. Assert a valid national UK number with its leading zero and its already-international equivalent normalize to the same +44 value. Assert empty/invalid numbers return null and US/Canada fixtures parse under their selected ISO country.
- [ ] Run `flutter test test/validation_test.dart`; confirm failure because these behaviors are not implemented.
- [ ] Implement the exact interfaces above using `phone_numbers_parser` for phone parsing and validity. Trim names/email for validation; do not trim or modify passwords. Set a clearly stated 8-character demo password minimum.
- [ ] Rerun `flutter test test/validation_test.dart`; require all cases to pass. Commit the project foundation and validation behavior when Git is configured.

## Task 2: Build and test the country/phone control

**Files:** `lib/widgets/country_phone_field.dart`, `test/country_phone_field_test.dart`.

**Interfaces:** `CountryPhoneField({Key? key, required TextEditingController controller, required Country country, required ValueChanged<Country> onCountryChanged, String? errorText})`. Selection is owned by the form, text by the supplied controller. Provide `Country initialCountry(Locale locale)` using the package's country list, with US fallback.

- [ ] Write widget tests that render a US selection, open the package picker, search for Canada, choose it, and assert the callback receives `CA` with phoneCode `1`. Assert selecting Pakistan produces `PK` and `92`. Assert closing the picker retains pretyped text and the old selection. Test locale `en_GB` yields GB and a language-only or unsupported-country locale yields US.
- [ ] Run `flutter test test/country_phone_field_test.dart`; confirm these tests fail before implementation.
- [ ] Implement the controlled field with flag/dial-code button, accessible country label, national phone keyboard, and `showCountryPicker`. Keep country data and searchable sheet supplied by the package. Do not trigger selection callbacks merely by opening or cancelling the sheet.
- [ ] Rerun the widget tests and the validation tests; require both to pass. Commit the control when Git is configured.

## Task 3: Recreate the screens and connect demo forms

**Files:** `lib/main.dart`, `lib/app.dart`, `lib/theme.dart`, the three page files, `lib/widgets/auth_shell.dart`, `lib/widgets/labeled_field.dart`, `assets/`, `test/app_test.dart`.

**Interfaces:** `HiGoApp` exposes routes `/`, `/login`, and `/register`. `AuthShell` supplies the shared responsive photo/form layout; `LabeledField` supplies a label and `TextFormField` with optional password visibility. Pages consume Tasks 1 and 2.

- [ ] Write application tests for Home → Register, Home → Login, and Login ↔ Register. Assert registration refuses empty fields, a mismatched password, invalid phone, and missing terms acceptance; assert a valid completed form displays a local-demo confirmation. Assert password visibility toggles do not change input text, and opening the picker preserves the form. Test a short viewport with keyboard inset and increased text scale for absence of layout overflow and reachable submission.
- [ ] Run `flutter test test/app_test.dart`; confirm failure because the application behavior is absent.
- [ ] Implement the shared theme and asset-backed shell, then Home, Login, and Register to the inspected references. Keep the white rounded panels, pale fields, purple buttons, and Poppins hierarchy. Use scrolling layouts and constrained widths rather than scaling the whole form. Correct obvious spelling errors.
- [ ] Wire navigation, controller lifecycle, field validators, terms acceptance, password toggles, and local-demo confirmations. Legal and password-reset affordances clearly explain that content/service is not configured. Never persist credentials.
- [ ] Run `flutter test`; require the full suite to pass. Commit the completed screens when Git is configured.

## Task 4: Verify locally and deliver

**Files:** `README.md`, any fixes justified by verification, and user-facing preview captures/instructions.

- [ ] Run `dart format --output=none --set-exit-if-changed lib test` after formatting, `flutter analyze`, and `flutter test`. Resolve failures and rerun only the affected checks plus the final suite.
- [ ] Build a supported local target, preferably web for convenient preview, and run it. Inspect the rendered Home, Login, Register, and searchable picker at 393 × 852 and on a wider desktop viewport. Check scrolling, keyboard space, country selection, shared dial codes, and form validation manually.
- [ ] If any reference assets are unavailable, document the exact visual differences rather than claiming pixel-identical reproduction. Fix discovered behavior bugs with regression tests before marking completion.
- [ ] Write concise run instructions, dependency/source attribution, and demo boundaries in `README.md`. Provide a link to the running preview and a source archive in this chat's `outputs` directory if useful, while retaining the working project at the requested location.
- [ ] Review the final diff against the approved design. Commit the validated result when Git is configured, then report test/build evidence and remaining limitations.

## Plan review

Coverage checked against the approved design: all three screens, shared styling/assets, package-based country selection, ISO/dial-code ownership, national/international phone handling, demo authentication boundaries, validation, small-screen behavior, tests, and local preview are assigned above. No backend or country-table work is included. Approved by the user on 2026-10-13 for direct inline execution. Implemented; see VERIFICATION.md for evidence.

