import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../config/assets.dart';
import '../model/chat/chat.dart';

class ChatApi {
  Router get router {
    final router =
        Router()
          ..get('/', (Request request) async {
            try {
              final type =
                  request
                      .url
                      .queryParameters['type']; // all, direct, group, channel, bot
              final search = request.url.queryParameters['search'];

              List<Chat> filteredChats = Assets.chats;

              if (type != null && type != 'all') {
                filteredChats =
                    filteredChats
                        .where(
                          (chat) =>
                              chat.type.toString().split('.').last == type,
                        )
                        .toList();
              }

              if (search != null && search.isNotEmpty) {
                filteredChats =
                    filteredChats
                        .where(
                          (chat) => chat.name.toLowerCase().contains(
                            search.toLowerCase(),
                          ),
                        )
                        .toList();
              }

              filteredChats.sort(
                (a, b) => b.lastMessageTime.compareTo(a.lastMessageTime),
              );

              return Response.ok(
                json.encode(
                  filteredChats.map((chat) => chat.toJson()).toList(),
                ),
                headers: {'Content-Type': 'application/json'},
              );
            } catch (e) {
              return Response.internalServerError(
                body: json.encode({'error': 'Failed to fetch chats: $e'}),
                headers: {'Content-Type': 'application/json'},
              );
            }
          })
          ..get('/<id>', (Request request, String id) async {
            try {
              final chat = Assets.chats.firstWhere(
                (chat) => chat.id == id,
                orElse: () => throw Exception('Chat not found'),
              );

              return Response.ok(
                json.encode(chat.toJson()),
                headers: {'Content-Type': 'application/json'},
              );
            } catch (e) {
              return Response.notFound(
                json.encode({'error': 'Chat not found: $e'}),
                headers: {'Content-Type': 'application/json'},
              );
            }
          })
          ..delete('/<id>', (Request request, String id) async {
            try {
              final chatsJson = await Assets.loadJsonFile('chats.json');
              final chats = (chatsJson as List).cast<Map<String, dynamic>>();

              final chatIndex = chats.indexWhere((chat) => chat['id'] == id);
              if (chatIndex == -1) {
                return Response.notFound(
                  json.encode({'error': 'Chat not found'}),
                  headers: {'Content-Type': 'application/json'},
                );
              }

              chats.removeAt(chatIndex);
              await Assets.saveJsonFile('chats.json', chats);

              return Response.ok(
                json.encode({'message': 'Chat deleted successfully'}),
                headers: {'Content-Type': 'application/json'},
              );
            } catch (e) {
              return Response.internalServerError(
                body: json.encode({'error': 'Failed to delete chat: $e'}),
                headers: {'Content-Type': 'application/json'},
              );
            }
          });

    return router;
  }
}
