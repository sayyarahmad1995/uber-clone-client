import 'package:flutter_test/flutter_test.dart';
import 'package:higo_countrycode/rider/camera_animation.dart';

void main() {
  testWidgets('animation remains guarded until idle, then allows manual pan', (
    tester,
  ) async {
    final animation = CameraAnimation();
    animation.start();
    await tester.pump(const Duration(milliseconds: 200));
    expect(animation.active, isTrue);
    animation.finish();
    expect(animation.active, isFalse);
    animation.dispose();
  });
  testWidgets('no-op animation cannot leave camera guarded indefinitely', (
    tester,
  ) async {
    final animation = CameraAnimation();
    animation.start();
    await tester.pump(const Duration(seconds: 2));
    expect(animation.active, isFalse);
    animation.dispose();
  });
}
