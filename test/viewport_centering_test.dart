import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:higo_countrycode/rider/viewport_centering.dart';

void main() {
  test(
    'resize requests combine within a frame and do not queue parallel camera moves',
    () async {
      final frames = <VoidCallback>[];
      final moves = <Completer<void>>[];
      final centering = ViewportCentering(
        scheduleAfterLayout: frames.add,
        center: () {
          final move = Completer<void>();
          moves.add(move);
          return move.future;
        },
      );
      addTearDown(centering.dispose);
      centering.resize(const Size(393, 400));
      centering.resize(const Size(393, 380));
      expect(frames, hasLength(1));
      expect(centering.isUpdating, isTrue);
      frames.removeAt(0)();
      expect(moves, hasLength(1));
      expect(centering.isUpdating, isTrue);
      centering.resize(const Size(393, 360));
      centering.resize(const Size(393, 340));
      expect(frames, isEmpty);
      expect(moves, hasLength(1));
      moves[0].complete();
      await Future<void>.delayed(Duration.zero);
      expect(frames, hasLength(1));
      frames.removeAt(0)();
      expect(moves, hasLength(2));
      moves[1].complete();
      await Future<void>.delayed(Duration.zero);
      centering.resize(const Size(393, 340));
      expect(frames, isEmpty);
      expect(centering.isUpdating, isFalse);
    },
  );

  test('disposing before the next frame prevents a camera update', () {
    final frames = <VoidCallback>[];
    var moves = 0;
    final centering = ViewportCentering(
      scheduleAfterLayout: frames.add,
      center: () async {
        moves++;
      },
    );
    centering.resize(const Size(393, 400));
    centering.dispose();
    frames.single();
    expect(moves, 0);
  });
}
