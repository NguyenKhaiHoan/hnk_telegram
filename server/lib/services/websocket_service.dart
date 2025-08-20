import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static final Map<String, Set<WebSocketChannel>> _chatSubscriptions = {};
  static final Map<WebSocketChannel, String> _channelToUser = {};

  /// Handle WebSocket connections
  static Handler createWebSocketHandler() {
    return webSocketHandler((WebSocketChannel webSocket) {
      print('🔌 New WebSocket connection established');

      webSocket.stream.listen(
        (message) {
          try {
            final data = json.decode(message as String) as Map<String, dynamic>;
            _handleMessage(webSocket, data);
          } catch (e) {
            print('❌ Error parsing WebSocket message: $e');
            _sendError(webSocket, 'Invalid message format');
          }
        },
        onDone: () {
          print('🔌 WebSocket connection closed');
          _removeConnection(webSocket);
        },
        onError: (error) {
          print('❌ WebSocket error: $error');
          _removeConnection(webSocket);
        },
      );
    });
  }

  /// Handle incoming WebSocket messages
  static void _handleMessage(
    WebSocketChannel webSocket,
    Map<String, dynamic> data,
  ) {
    final type = data['type'] as String?;

    switch (type) {
      case 'join_chat':
        _handleJoinChat(webSocket, data);
        break;
      case 'leave_chat':
        _handleLeaveChat(webSocket, data);
        break;
      case 'typing':
        _handleTyping(webSocket, data);
        break;
      default:
        _sendError(webSocket, 'Unknown message type: $type');
    }
  }

  /// Handle user joining a chat
  static void _handleJoinChat(
    WebSocketChannel webSocket,
    Map<String, dynamic> data,
  ) {
    final chatId = data['chat_id'] as String?;
    final userId = data['user_id'] as String?;

    if (chatId == null || userId == null) {
      _sendError(webSocket, 'Missing chat_id or user_id');
      return;
    }

    // Remove from previous chat if any
    _removeConnection(webSocket);

    // Add to new chat
    _chatSubscriptions.putIfAbsent(chatId, () => {}).add(webSocket);
    _channelToUser[webSocket] = userId;

    print('👥 User $userId joined chat $chatId');

    _sendToChannel(webSocket, {
      'type': 'join_success',
      'chat_id': chatId,
      'message': 'Successfully joined chat',
    });

    // Notify other users in chat
    _broadcastToChat(chatId, {
      'type': 'user_joined',
      'user_id': userId,
      'chat_id': chatId,
    }, exclude: webSocket);
  }

  /// Handle user leaving a chat
  static void _handleLeaveChat(
    WebSocketChannel webSocket,
    Map<String, dynamic> data,
  ) {
    final chatId = data['chat_id'] as String?;
    final userId = _channelToUser[webSocket];

    if (chatId != null && userId != null) {
      _removeFromChat(webSocket, chatId);

      // Notify other users
      _broadcastToChat(chatId, {
        'type': 'user_left',
        'user_id': userId,
        'chat_id': chatId,
      });
    }
  }

  /// Handle typing indicators
  static void _handleTyping(
    WebSocketChannel webSocket,
    Map<String, dynamic> data,
  ) {
    final chatId = data['chat_id'] as String?;
    final userId = _channelToUser[webSocket];
    final isTyping = data['is_typing'] as bool? ?? false;

    if (chatId != null && userId != null) {
      _broadcastToChat(chatId, {
        'type': 'typing',
        'user_id': userId,
        'chat_id': chatId,
        'is_typing': isTyping,
      }, exclude: webSocket);
    }
  }

  /// Broadcast new message to all users in a chat
  static void broadcastMessage(String chatId, Map<String, dynamic> message) {
    _broadcastToChat(chatId, {
      'type': 'new_message',
      'chat_id': chatId,
      'message': message,
    });
  }

  /// Send message to specific channel
  static void _sendToChannel(
    WebSocketChannel channel,
    Map<String, dynamic> data,
  ) {
    try {
      channel.sink.add(json.encode(data));
    } catch (e) {
      print('❌ Error sending to channel: $e');
      _removeConnection(channel);
    }
  }

  /// Broadcast to all users in a chat
  static void _broadcastToChat(
    String chatId,
    Map<String, dynamic> data, {
    WebSocketChannel? exclude,
  }) {
    final channels = _chatSubscriptions[chatId];
    if (channels == null) return;

    final deadChannels = <WebSocketChannel>[];

    for (final channel in channels) {
      if (channel == exclude) continue;

      try {
        channel.sink.add(json.encode(data));
      } catch (e) {
        print('❌ Dead channel found, will remove: $e');
        deadChannels.add(channel);
      }
    }

    // Clean up dead channels
    for (final deadChannel in deadChannels) {
      _removeConnection(deadChannel);
    }
  }

  /// Remove connection from all subscriptions
  static void _removeConnection(WebSocketChannel webSocket) {
    final userId = _channelToUser.remove(webSocket);

    // Remove from all chat subscriptions
    for (final entry in _chatSubscriptions.entries) {
      final chatId = entry.key;
      final channels = entry.value;

      if (channels.remove(webSocket) && userId != null) {
        // Notify remaining users that this user left
        _broadcastToChat(chatId, {
          'type': 'user_left',
          'user_id': userId,
          'chat_id': chatId,
        });
      }
    }

    // Clean up empty chat subscriptions
    _chatSubscriptions.removeWhere((_, channels) => channels.isEmpty);
  }

  /// Remove connection from specific chat
  static void _removeFromChat(WebSocketChannel webSocket, String chatId) {
    final channels = _chatSubscriptions[chatId];
    channels?.remove(webSocket);

    if (channels?.isEmpty ?? false) {
      _chatSubscriptions.remove(chatId);
    }
  }

  /// Send error message to channel
  static void _sendError(WebSocketChannel channel, String error) {
    _sendToChannel(channel, {'type': 'error', 'error': error});
  }

  /// Get connection stats
  static Map<String, dynamic> getStats() {
    final chatCount = _chatSubscriptions.length;
    final totalConnections = _channelToUser.length;
    final chatDetails = <String, int>{};

    for (final entry in _chatSubscriptions.entries) {
      chatDetails[entry.key] = entry.value.length;
    }

    return {
      'total_connections': totalConnections,
      'active_chats': chatCount,
      'chat_details': chatDetails,
    };
  }
}
