import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../config/assets.dart';
import '../services/websocket_service.dart';

class MessageApi {
  Router get router {
    final router =
        Router()
          ..get('/chat/<chatId>', (Request request, String chatId) async {
            try {
              final limit =
                  int.tryParse(request.url.queryParameters['limit'] ?? '50') ??
                  5;
              final offset =
                  int.tryParse(request.url.queryParameters['offset'] ?? '0') ??
                  0;

              // Load messages from JSON data
              final messagesJson = await Assets.loadJsonFile('messages.json');
              final messagesData =
                  (messagesJson as List).cast<Map<String, dynamic>>();

              // Load users data
              final usersJson = await Assets.loadJsonFile('users.json');
              final usersData =
                  (usersJson as List).cast<Map<String, dynamic>>();

              // Filter messages for this chat
              final chatMessages =
                  messagesData
                      .where((msg) => msg['chat_id'] == chatId)
                      .toList();

              // Sort by timestamp (newest first)
              chatMessages.sort(
                (a, b) => b['timestamp'].compareTo(a['timestamp']),
              );

              final endIndex = (offset + limit).clamp(0, chatMessages.length);
              final startIndex = offset.clamp(0, chatMessages.length);
              final paginatedMessages = chatMessages.sublist(
                startIndex,
                endIndex,
              );

              // Enrich messages with user info
              final enrichedMessages =
                  paginatedMessages.map((msg) {
                    final senderId = msg['sender_id'] as String;
                    final user = usersData.firstWhere(
                      (u) => u['id'] == senderId,
                      orElse:
                          () => {
                            'id': senderId,
                            'name': 'Unknown User',
                            'profile_picture': null,
                          },
                    );

                    return {
                      'id': msg['id'],
                      'chat_id': msg['chat_id'],
                      'sender': {
                        'id': user['id'],
                        'name': user['name'],
                        'profile_picture': user['profile_picture'],
                      },
                      'content': msg['content'],
                      'type': msg['type'],
                      'status': msg['status'],
                      'timestamp': msg['timestamp'],
                      'reply_to_message_id': msg['reply_to_message_id'],
                      'location': msg['location'],
                      'link_preview': msg['link_preview'],
                      'file_info': msg['file_info'],
                    };
                  }).toList();

              final hasMore = endIndex < chatMessages.length;

              return Response.ok(
                json.encode({
                  'messages': enrichedMessages,
                  'hasMore': hasMore,
                  'chatId': chatId,
                  'limit': limit,
                  'offset': offset,
                  'total': chatMessages.length,
                }),
                headers: {'Content-Type': 'application/json'},
              );
            } catch (e) {
              return Response.internalServerError(
                body: json.encode({'error': 'Failed to fetch messages: $e'}),
                headers: {'Content-Type': 'application/json'},
              );
            }
          })
          ..post('/', (Request request) async {
            try {
              final body = await request.readAsString();
              final messageData = json.decode(body) as Map<String, Object?>;

              if (!messageData.containsKey('chat_id') ||
                  !messageData.containsKey('content') ||
                  !messageData.containsKey('type')) {
                return Response.badRequest(
                  body: json.encode({
                    'error': 'Missing required fields: chat_id, content, type',
                  }),
                  headers: {'Content-Type': 'application/json'},
                );
              }

              final messageType = messageData['type'] as String;
              switch (messageType) {
                case 'link':
                  if (!messageData.containsKey('link_preview')) {
                    return Response.badRequest(
                      body: json.encode({
                        'error': 'Link messages require linkPreview data',
                      }),
                      headers: {'Content-Type': 'application/json'},
                    );
                  }
                  break;
                case 'location':
                  if (!messageData.containsKey('location')) {
                    return Response.badRequest(
                      body: json.encode({
                        'error': 'Location messages require location data',
                      }),
                      headers: {'Content-Type': 'application/json'},
                    );
                  }
                  break;
                case 'file':
                  if (!messageData.containsKey('file_info')) {
                    return Response.badRequest(
                      body: json.encode({
                        'error': 'File messages require fileInfo data',
                      }),
                      headers: {'Content-Type': 'application/json'},
                    );
                  }
                  break;
              }

              final messagesJson = await Assets.loadJsonFile('messages.json');
              final messages =
                  (messagesJson as List).cast<Map<String, dynamic>>();

              // Create new message
              final newMessageData = {
                'id': 'msg_${messages.length + 1}',
                'chat_id': messageData['chat_id'] as String,
                'sender_id': messageData['sender_id'] as String,
                'content': messageData['content'] as String,
                'type': messageData['type'] as String,
                'status': 'sent', // Set as sent
                'timestamp': DateTime.now().toIso8601String(),
                'reply_to_message_id':
                    messageData['reply_to_message_id'] as String?,
                'link_preview':
                    messageData['link_preview'] as Map<String, dynamic>?,
                'location': messageData['location'] as Map<String, dynamic>?,
                'file_info': messageData['file_info'] as Map<String, dynamic>?,
              };

              messages.add(newMessageData);
              await Assets.saveJsonFile('messages.json', messages);

              // Load users data to enrich response
              final usersJson = await Assets.loadJsonFile('users.json');
              final usersData =
                  (usersJson as List).cast<Map<String, dynamic>>();

              final senderId = messageData['sender_id'] as String;
              final user = usersData.firstWhere(
                (u) => u['id'] == senderId,
                orElse:
                    () => {
                      'id': senderId,
                      'name': 'Unknown User',
                      'profile_picture': null,
                    },
              );

              // Return enriched message
              final enrichedMessage = {
                'id': newMessageData['id'],
                'chat_id': newMessageData['chat_id'],
                'sender': {
                  'id': user['id'],
                  'name': user['name'],
                  'profile_picture': user['profile_picture'],
                },
                'content': newMessageData['content'],
                'type': newMessageData['type'],
                'status': newMessageData['status'],
                'timestamp': newMessageData['timestamp'],
                'reply_to_message_id': newMessageData['reply_to_message_id'],
                'location': newMessageData['location'],
                'link_preview': newMessageData['link_preview'],
                'file_info': newMessageData['file_info'],
              };

              // 🔄 Broadcast message to all connected users in this chat
              final chatId = newMessageData['chat_id'] as String;
              WebSocketService.broadcastMessage(chatId, enrichedMessage);

              return Response.ok(
                json.encode(enrichedMessage),
                headers: {'Content-Type': 'application/json'},
              );
            } catch (e) {
              return Response.badRequest(
                body: json.encode({'error': 'Invalid message data'}),
                headers: {'Content-Type': 'application/json'},
              );
            }
          })
          ..put('/<id>', (Request request, String id) async {
            try {
              final body = await request.readAsString();
              final messageData = json.decode(body) as Map<String, Object?>;

              final messagesJson = await Assets.loadJsonFile('messages.json');
              final messages =
                  (messagesJson as List).cast<Map<String, dynamic>>();

              final messageIndex = messages.indexWhere(
                (msg) => msg['id'] == id,
              );
              if (messageIndex == -1) {
                return Response.notFound(
                  json.encode({'error': 'Message not found'}),
                  headers: {'Content-Type': 'application/json'},
                );
              }

              messages[messageIndex] = messageData;
              await Assets.saveJsonFile('messages.json', messages);

              return Response.ok(
                json.encode({'message': 'Message updated successfully'}),
                headers: {'Content-Type': 'application/json'},
              );
            } catch (e) {
              return Response.badRequest(
                body: json.encode({'error': 'Invalid message data: $e'}),
                headers: {'Content-Type': 'application/json'},
              );
            }
          })
          ..delete('/<id>', (Request request, String id) async {
            try {
              final messagesJson = await Assets.loadJsonFile('messages.json');
              final messages =
                  (messagesJson as List).cast<Map<String, dynamic>>();

              final messageIndex = messages.indexWhere(
                (msg) => msg['id'] == id,
              );
              if (messageIndex == -1) {
                return Response.notFound(
                  json.encode({'error': 'Message not found'}),
                  headers: {'Content-Type': 'application/json'},
                );
              }

              messages.removeAt(messageIndex);
              await Assets.saveJsonFile('messages.json', messages);

              return Response.ok(
                json.encode({'message': 'Message deleted successfully'}),
                headers: {'Content-Type': 'application/json'},
              );
            } catch (e) {
              return Response.internalServerError(
                body: json.encode({'error': 'Failed to delete message: $e'}),
                headers: {'Content-Type': 'application/json'},
              );
            }
          })
          ..put('/<id>/read', (Request request, String id) async {
            try {
              final messagesJson = await Assets.loadJsonFile('messages.json');
              final messages =
                  (messagesJson as List).cast<Map<String, dynamic>>();

              final messageIndex = messages.indexWhere(
                (msg) => msg['id'] == id,
              );
              if (messageIndex == -1) {
                return Response.notFound(
                  json.encode({'error': 'Message not found'}),
                  headers: {'Content-Type': 'application/json'},
                );
              }

              messages[messageIndex]['status'] = 'read';
              await Assets.saveJsonFile('messages.json', messages);

              return Response.ok(
                json.encode({'message': 'Message marked as read'}),
                headers: {'Content-Type': 'application/json'},
              );
            } catch (e) {
              return Response.internalServerError(
                body: json.encode({
                  'error': 'Failed to mark message as read: $e',
                }),
                headers: {'Content-Type': 'application/json'},
              );
            }
          })
          ..post('/<id>/reply', (Request request, String id) async {
            try {
              final body = await request.readAsString();
              final replyData = json.decode(body) as Map<String, Object?>;

              if (!replyData.containsKey('content') ||
                  !replyData.containsKey('type')) {
                return Response.badRequest(
                  body: json.encode({
                    'error': 'Missing required fields: content, type',
                  }),
                  headers: {'Content-Type': 'application/json'},
                );
              }

              return Response.ok(
                json.encode({
                  'message': 'Reply sent successfully',
                  'messageId': 'new_reply_id',
                  'replyToMessageId': id,
                  'timestamp': DateTime.now().toIso8601String(),
                }),
                headers: {'Content-Type': 'application/json'},
              );
            } catch (e) {
              return Response.badRequest(
                body: json.encode({'error': 'Invalid reply data'}),
                headers: {'Content-Type': 'application/json'},
              );
            }
          })
          ..post('/<id>/reaction', (Request request, String id) async {
            try {
              final body = await request.readAsString();
              final reactionData = json.decode(body) as Map<String, Object?>;

              if (!reactionData.containsKey('user_id') ||
                  !reactionData.containsKey('emoji')) {
                return Response.badRequest(
                  body: json.encode({
                    'error': 'Missing required fields: user_id, emoji',
                  }),
                  headers: {'Content-Type': 'application/json'},
                );
              }

              return Response.ok(
                json.encode({
                  'message': 'Reaction added successfully',
                  'messageId': id,
                  'user_id': reactionData['user_id'],
                  'emoji': reactionData['emoji'],
                }),
                headers: {'Content-Type': 'application/json'},
              );
            } catch (e) {
              return Response.badRequest(
                body: json.encode({'error': 'Invalid reaction data'}),
                headers: {'Content-Type': 'application/json'},
              );
            }
          })
          ..post('/<id>/forward', (Request request, String id) async {
            try {
              final body = await request.readAsString();
              final forwardData = json.decode(body) as Map<String, Object?>;

              if (!forwardData.containsKey('target_chat_Id')) {
                return Response.badRequest(
                  body: json.encode({
                    'error': 'Missing required field: target_chat_id',
                  }),
                  headers: {'Content-Type': 'application/json'},
                );
              }

              return Response.ok(
                json.encode({
                  'message': 'Message forwarded successfully',
                  'messageId': id,
                  'targetChatId': forwardData['target_chat_id'],
                  'timestamp': DateTime.now().toIso8601String(),
                }),
                headers: {'Content-Type': 'application/json'},
              );
            } catch (e) {
              return Response.badRequest(
                body: json.encode({'error': 'Invalid forward data'}),
                headers: {'Content-Type': 'application/json'},
              );
            }
          });

    return router;
  }
}
