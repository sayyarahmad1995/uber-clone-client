import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import '../tool/maps_configuration.dart';

void main() {
  late Directory root;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('higo-maps-test-');
    await Directory('${root.path}/android').create();
    await Directory('${root.path}/web').create();
  });
  tearDown(() async => root.delete(recursive: true));
  test(
    'web configuration uses its own key and missing key clears stale output',
    () async {
      final file = File('${root.path}/android/secretes.properties');
      await file.writeAsString(
        'GOOGLE_MAPS_API_KEY=android-test-key\nGOOGLE_MAPS_WEB_API_KEY=web-test-key\n',
      );
      expect(await prepareMapsConfiguration(root, 'web'), isTrue);
      final output = File('${root.path}/web/maps-config.js');
      final text = await output.readAsString();
      expect(text, contains('web-test-key'));
      expect(text, isNot(contains('android-test-key')));
      await file.writeAsString('GOOGLE_MAPS_API_KEY=android-test-key\n');
      expect(await prepareMapsConfiguration(root, 'web'), isFalse);
      expect(await output.readAsString(), isNot(contains('web-test-key')));
      expect(await prepareMapsConfiguration(root, 'android'), isTrue);
    },
  );
  test(
    'missing secrets produce unconfigured state without exposing a key',
    () async {
      expect(await prepareMapsConfiguration(root, 'android'), isFalse);
      expect(await prepareMapsConfiguration(root, 'web'), isFalse);
      expect(
        await File('${root.path}/web/maps-config.js').readAsString(),
        contains('null'),
      );
    },
  );
}
