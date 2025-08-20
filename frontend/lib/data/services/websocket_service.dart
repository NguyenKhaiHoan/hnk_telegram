import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:telegram_frontend/data/services/api/model/message/message_api_model.dart';
import 'package:telegram_frontend/data/translators/message_translator.dart';
import 'package:telegram_frontend/domain/models/message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static const String _baseUrl = 'ws://localhost:8080/ws';

  WebSocketChannel? _channel;
  String? _currentChatId;
  String? _currentUserId;

  final _messageController = StreamController<Message>.broadcast();
  final _typingController = StreamController<TypingEvent>.broadcast();
  final _connectionController = StreamController<ConnectionStatus>.broadcast();

  final _log = Logger('WebSocketService');

  // Streams
  Stream<Message> get messageStream => _messageController.stream;
  Stream<TypingEvent> get typingStream => _typingController.stream;
  Stream<ConnectionStatus> get connectionStream => _connectionController.stream;

  // Connection status
  bool get isConnected => _channel != null;

  /// Connect to WebSocket server
  Future<void> connect() async {
    if (_channel != null) {
      _log.info('WebSocket already connected');
      return;
    }

    try {
      _log.info('🔌 Connecting to WebSocket: $_baseUrl');
      _channel = WebSocketChannel.connect(Uri.parse(_baseUrl));

      // Listen to messages
      _channel!.stream.listen(
        _handleMessage,
        onDone: () {
          _log.info('🔌 WebSocket connection closed');
          _connectionController.add(ConnectionStatus.disconnected);
          _cleanup();
        },
        onError: (Object error) {
          _log.severe('❌ WebSocket error: $error');
          _connectionController.add(ConnectionStatus.error);
          _cleanup();
        },
      );

      _connectionController.add(ConnectionStatus.connected);
      _log.info('✅ WebSocket connected successfully');
    } catch (e) {
      _log.severe('❌ Failed to connect WebSocket: $e');
      _connectionController.add(ConnectionStatus.error);
      _cleanup();
    }
  }

  /// Disconnect from WebSocket
  void disconnect() {
    _log.info('🔌 Disconnecting WebSocket');
    _channel?.sink.close();
    _cleanup();
  }

  /// Join a chat room
  Future<void> joinChat(String chatId, String userId) async {
    if (_channel == null) {
      await connect();
    }

    _currentChatId = chatId;
    _currentUserId = userId;

    _sendMessage({
      'type': 'join_chat',
      'chat_id': chatId,
      'user_id': userId,
    });

    _log.info('👥 Joined chat: $chatId');
  }

  /// Leave current chat
  void leaveChat() {
    if (_currentChatId != null && _currentUserId != null) {
      _sendMessage({
        'type': 'leave_chat',
        'chat_id': _currentChatId,
        'user_id': _currentUserId,
      });

      _log.info('👥 Left chat: $_currentChatId');
      _currentChatId = null;
      _currentUserId = null;
    }
  }

  /// Send typing indicator
  void sendTyping({required bool isTyping}) {
    if (_currentChatId != null && _currentUserId != null) {
      _sendMessage({
        'type': 'typing',
        'chat_id': _currentChatId,
        'user_id': _currentUserId,
        'is_typing': isTyping,
      });
    }
  }

  /// Send message to WebSocket
  void _sendMessage(Map<String, dynamic> message) {
    try {
      _channel?.sink.add(json.encode(message));
    } catch (e) {
      _log.severe('❌ Failed to send WebSocket message: $e');
    }
  }

  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic data) {
    try {
      final message = json.decode(data as String) as Map<String, dynamic>;
      final type = message['type'] as String;

      _log.info('📨 Received WebSocket message: $type');

      switch (type) {
        case 'new_message':
          _handleNewMessage(message);
        case 'typing':
          _handleTyping(message);
        case 'user_joined':
          _log.info('👥 User joined: ${message['user_id']}');
        case 'user_left':
          _log.info('👥 User left: ${message['user_id']}');
        case 'join_success':
          _log.info('✅ Successfully joined chat: ${message['chat_id']}');
        case 'error':
          _log.severe('❌ WebSocket error: ${message['error']}');
        default:
          _log.warning('⚠️ Unknown message type: $type');
      }
    } catch (e) {
      _log.severe('❌ Failed to handle WebSocket message: $e');
    }
  }

  /// Handle new message from WebSocket
  void _handleNewMessage(Map<String, dynamic> data) {
    try {
      final messageData = data['message'] as Map<String, dynamic>;
      final apiMessage = MessageApiModel.fromJson(messageData);
      final domainMessage = MessageTranslator().toDomain(apiMessage);

      _messageController.add(domainMessage);
      _log.info('💬 New message received: ${domainMessage.id}');
    } catch (e) {
      _log.severe('❌ Failed to parse new message: $e');
    }
  }

  /// Handle typing indicator
  void _handleTyping(Map<String, dynamic> data) {
    try {
      final userId = data['user_id'] as String;
      final chatId = data['chat_id'] as String;
      final isTyping = data['is_typing'] as bool;

      _typingController.add(
        TypingEvent(
          userId: userId,
          chatId: chatId,
          isTyping: isTyping,
        ),
      );
    } catch (e) {
      _log.severe('❌ Failed to parse typing event: $e');
    }
  }

  /// Cleanup resources
  void _cleanup() {
    _channel = null;
    _currentChatId = null;
    _currentUserId = null;
  }

  /// Dispose all resources
  void dispose() {
    disconnect();
    _messageController.close();
    _typingController.close();
    _connectionController.close();
  }
}

// Events
class TypingEvent {
  const TypingEvent({
    required this.userId,
    required this.chatId,
    required this.isTyping,
  });

  final String userId;
  final String chatId;
  final bool isTyping;
}

enum ConnectionStatus {
  connected,
  disconnected,
  error,
}
