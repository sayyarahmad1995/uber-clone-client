import 'dart:async';

/// Native animateCamera acknowledges the command before motion finishes.
class CameraAnimation {
  static const duration = Duration(milliseconds: 600);
  Timer? _expiry;
  bool active = false;

  void start() {
    _expiry?.cancel();
    active = true;
    // A no-op camera update may not emit an idle event.
    _expiry = Timer(const Duration(seconds: 2), finish);
  }

  void finish() {
    _expiry?.cancel();
    active = false;
  }

  void dispose() => finish();
}
