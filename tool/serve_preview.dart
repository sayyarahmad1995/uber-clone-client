import 'dart:io';

// Local-only preview: serves build/web and forwards a narrow set of application
// API calls to the development server. No credentials or request bodies logged.
Future<void> main(List<String> args) async {
  final port = args.isEmpty ? 5175 : int.parse(args.first);
  final root = Directory('build/web').absolute;
  if (!File('${root.path}/index.html').existsSync()) {
    throw StateError('Build web first.');
  }
  final upstream = HttpClient()
    ..connectionTimeout = const Duration(seconds: 15);
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  stdout.writeln('HiGO preview: http://127.0.0.1:$port/#/rider');
  await for (final request in server) {
    () async {
      try {
        final path = request.uri.path;
        if (path.startsWith('/api/')) {
          final origin = request.headers.value('origin');
          if (origin != null && origin != 'http://127.0.0.1:$port') {
            request.response.statusCode = 403;
            return;
          }
          final apiPath = path.substring(4);
          final allowedPost = {
            '/v1/auth/login',
            '/v1/places/autocomplete',
            '/v1/places/reverse-geocode',
            '/v1/ride-previews',
          };
          final allowed =
              (request.method == 'POST' && allowedPost.contains(apiPath)) ||
              (request.method == 'GET' &&
                  (apiPath == '/v1/ride-services' ||
                      RegExp(r'^/v1/places/[^/]+$').hasMatch(apiPath)));
          if (!allowed) {
            request.response.statusCode = 404;
            return;
          }
          final bytes = <int>[];
          await for (final chunk in request) {
            bytes.addAll(chunk);
            if (bytes.length > 65536) {
              request.response.statusCode = 413;
              return;
            }
          }
          final uri = Uri.https(
            'dev-api.higorides.com',
            apiPath,
            request.uri.queryParameters.isEmpty
                ? null
                : request.uri.queryParameters,
          );
          final forwarded = await upstream.openUrl(request.method, uri);
          forwarded.followRedirects = false;
          forwarded.headers.contentType = ContentType.json;
          final auth = request.headers.value('authorization');
          if (auth != null) forwarded.headers.set('authorization', auth);
          forwarded.add(bytes);
          final response = await forwarded.close().timeout(
            const Duration(seconds: 20),
          );
          request.response.statusCode = response.statusCode;
          request.response.headers.set(
            'content-type',
            response.headers.value('content-type') ?? 'application/json',
          );
          request.response.headers.set('cache-control', 'no-store');
          await request.response.addStream(response);
        } else {
          if (request.method != 'GET' && request.method != 'HEAD') {
            request.response.statusCode = 405;
            return;
          }
          if (request.uri.pathSegments.any(
            (s) => s == '..' || s.contains('\\'),
          )) {
            request.response.statusCode = 400;
            return;
          }
          final file = File(
            '${root.path}/${path == '/' ? 'index.html' : path.substring(1)}',
          );
          if (!await file.exists()) {
            request.response.statusCode = 404;
            return;
          }
          final extension = file.path.split('.').last;
          final type =
              {
                'html': 'text/html',
                'js': 'application/javascript',
                'json': 'application/json',
                'css': 'text/css',
                'wasm': 'application/wasm',
                'png': 'image/png',
                'ttf': 'font/ttf',
              }[extension] ??
              'application/octet-stream';
          request.response.headers.set('content-type', type);
          request.response.headers.set('cache-control', 'no-store');
          if (request.method == 'GET') {
            await request.response.addStream(file.openRead());
          }
        }
      } catch (_) {
        request.response.statusCode = 502;
        request.response.write('{"error":"Development service unavailable"}');
      } finally {
        await request.response.close();
      }
    }();
  }
}
