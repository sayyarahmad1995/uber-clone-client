import 'dart:io';
import 'maps_configuration.dart';

Future<void> main(List<String> args) async {
  if (args.length < 2 ||
      !['android', 'web'].contains(args[0]) ||
      !['run', 'build'].contains(args[1])) {
    stderr.writeln(
      'Usage: dart run tool/run_maps.dart <android|web> <run|build> [Flutter options]',
    );
    exitCode = 64;
    return;
  }
  final configured = await prepareMapsConfiguration(Directory.current, args[0]);
  stdout.writeln(
    configured
        ? 'Local map configuration loaded.'
        : 'Map key not configured; the UI preview remains available.',
  );
  final flutter =
      Platform.environment['FLUTTER_BIN'] ??
      (Platform.isWindows ? 'flutter.bat' : 'flutter');
  final command = [
    args[1],
    if (args[1] == 'build') args[0] == 'android' ? 'apk' : 'web',
    '--dart-define=MAPS_CONFIGURED=$configured',
    ...args.skip(2),
  ];
  final process = await Process.start(
    flutter,
    command,
    mode: ProcessStartMode.inheritStdio,
    runInShell: Platform.isWindows,
  );
  exitCode = await process.exitCode;
}
