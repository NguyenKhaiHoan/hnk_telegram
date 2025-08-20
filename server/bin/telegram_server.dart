import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:telegram_server/middleware/auth.dart';
import 'package:telegram_server/routes/login.dart';
import 'package:telegram_server/routes/user.dart';
import 'package:telegram_server/routes/chat.dart';
import 'package:telegram_server/routes/message.dart';
import 'package:telegram_server/routes/story.dart';
import 'package:telegram_server/config/assets.dart';
import 'package:telegram_server/services/websocket_service.dart';

// Configure routes.
final _router =
    Router()
      ..get('/', _rootHandler)
      ..get('/test', _testHandler)
      ..get('/debug-assets', _debugAssetsHandler)
      ..get('/ws', WebSocketService.createWebSocketHandler())
      ..mount('/users', UserApi().router.call)
      ..mount('/login', LoginApi().router.call)
      ..mount('/chats', ChatApi().router.call)
      ..mount('/messages', MessageApi().router.call)
      ..mount('/stories', StoryRoutes().router.call);

void main(List<String> args) async {
  print('🚀 Starting Telegram Server...');

  try {
    final ip = InternetAddress.anyIPv4;
    final port = int.parse(Platform.environment['PORT'] ?? '8080');

    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(authRequests())
        .addHandler(_router.call);

    // Start server with better error handling
    print('🔍 Binding to $ip:$port...');

    try {
      final server = await serve(handler, ip, port);
      log('🎉 Telegram Server started successfully!');
      log('📍 Address: http://${server.address.host}:${server.port}');

      print('🔄 Server is running. Press Ctrl+C to stop.');
    } catch (e) {
      print('  ❌ Error starting server on port $port: $e');

      // Try alternative port
      final altPort = port + 1;
      print('  🔍 Trying alternative port $altPort...');

      try {
        final server = await serve(handler, ip, altPort);
        log('🎉 Telegram Server started on port $altPort!');
        log('📍 Address: http://${server.address.host}:${server.port}');

        print('🔄 Server is running. Press Ctrl+C to stop.');
      } catch (e2) {
        print('❌ Error starting server on port $altPort: $e2');
        print('❌ Failed to start server on any port');
        return;
      }
    }
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('📚 Stack trace:');
    print(stackTrace);
  }
}

// Root handler
Response _rootHandler(Request request) {
  return Response.ok(
    json.encode({
      'message': 'Welcome to Telegram Server! 🎉',
      'status': 'running',
      'timestamp': DateTime.now().toIso8601String(),
      'endpoints': [],
    }),
    headers: {'Content-Type': 'application/json'},
  );
}

// Test handler
Response _testHandler(Request request) {
  return Response.ok(
    json.encode({
      'message': 'Test API works! ✅',
      'method': request.method,
      'url': request.url.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    }),
    headers: {'Content-Type': 'application/json'},
  );
}

// Debug assets handler
Response _debugAssetsHandler(Request request) {
  try {
    final users = Assets.users;
    final chats = Assets.chats;
    final messages = Assets.messages;
    final stories = Assets.stories;

    return Response.ok(
      json.encode({
        'message': 'Assets Debug Info',
        'users_count': users.length,
        'chats_count': chats.length,
        'messages_count': messages.length,
        'stories_count': stories.length,
        'users_sample':
            users
                .take(2)
                .map(
                  (u) => {
                    'id': u.id,
                    'email': u.email,
                    'name': u.name,
                    'isOnline': u.isOnline,
                  },
                )
                .toList(),
        'timestamp': DateTime.now().toIso8601String(),
      }),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e) {
    return Response.internalServerError(
      body: json.encode({
        'error': 'Failed to load assets',
        'message': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
