import 'dart:async';
import 'package:flutter/widgets.dart';

/// Recenters after layout, with one in-flight camera command and no drag delay.
class ViewportCentering {
  ViewportCentering({required this.scheduleAfterLayout, required this.center});
  final void Function(VoidCallback callback) scheduleAfterLayout;
  final Future<void> Function() center;
  Size? _size;
  bool _scheduled = false,
      _running = false,
      _pending = false,
      _disposed = false;

  bool get isUpdating => _scheduled || _running || _pending;

  void resize(Size size) {
    if (_disposed || size == _size || size.isEmpty) return;
    _size = size;
    recenter();
  }

  void recenter() {
    if (_disposed) return;
    _pending = true;
    _schedule();
  }

  void _schedule() {
    if (_disposed || _running || _scheduled) return;
    _scheduled = true;
    scheduleAfterLayout(() => unawaited(_flush()));
  }

  Future<void> _flush() async {
    _scheduled = false;
    if (_disposed || !_pending) return;
    _running = true;
    _pending = false;
    try {
      await center();
    } catch (_) {
      // A platform view may be replaced while a camera request is in flight.
      // Keep the UI responsive and retry on the next resize/recenter request.
    } finally {
      _running = false;
      if (_pending) _schedule();
    }
  }

  void dispose() {
    _disposed = true;
    _pending = false;
  }
}
