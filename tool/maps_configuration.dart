import 'dart:convert';
import 'dart:io';

/// Prepares only ignored web output; actual keys never enter tracked source.
Future<bool> prepareMapsConfiguration(Directory root, String platform) async {
  if (platform != 'android' && platform != 'web') {
    throw ArgumentError('Use android or web.');
  }
  final secrets = File('${root.path}/android/secretes.properties');
  final values = <String, String>{};
  if (await secrets.exists()) {
    for (final raw in await secrets.readAsLines()) {
      final line = raw.trim();
      if (line.isEmpty || line.startsWith('#') || line.startsWith('!')) {
        continue;
      }
      final separator = line.indexOf('=');
      if (separator > 0) {
        values[line.substring(0, separator).trim()] = line
            .substring(separator + 1)
            .trim();
      }
    }
  }
  final key =
      values[platform == 'android'
          ? 'GOOGLE_MAPS_API_KEY'
          : 'GOOGLE_MAPS_WEB_API_KEY'] ??
      '';
  final configured = key.isNotEmpty && !key.startsWith('YOUR_');
  if (platform == 'web') {
    await File('${root.path}/web/maps-config.js').writeAsString(
      'window.higoMapsApiKey = ${jsonEncode(configured ? key : null)};\n',
    );
  }
  return configured;
}
