import 'package:dartz/dartz.dart';
import 'package:logging/logging.dart';

import 'package:telegram_frontend/data/repositories/message/message_repository.dart';
import 'package:telegram_frontend/data/services/api/api_client.dart';

import 'package:telegram_frontend/data/services/websocket_service.dart';
import 'package:telegram_frontend/data/translators/message_translator.dart';
import 'package:telegram_frontend/domain/error/exception.dart';
import 'package:telegram_frontend/domain/error/failure.dart';
import 'package:telegram_frontend/domain/models/message.dart';
import 'package:telegram_frontend/domain/models/paginated_response.dart';
import 'package:telegram_frontend/utils/constant.dart';

class MessageRepositoryRemote implements MessageRepository {
  MessageRepositoryRemote({
    required ApiClient apiClient,
    required WebSocketService webSocketService,
  })  : _apiClient = apiClient,
        _webSocketService = webSocketService;

  final ApiClient _apiClient;
  final WebSocketService _webSocketService;
  final _log = Logger('MessageRepositoryRemote');

  // Expose WebSocket streams
  @override
  Stream<Message> get messageStream => _webSocketService.messageStream;
  @override
  Stream<TypingEvent> get typingStream => _webSocketService.typingStream;
  @override
  Stream<ConnectionStatus> get connectionStream =>
      _webSocketService.connectionStream;

  @override
  Future<Either<Failure, PaginatedResponse<Message>>> getPaginated(
    dynamic params, {
    int? limit,
    int? offset,
  }) async {
    try {
      final chatId = params as String;
      _log.info('Fetching messages for chat: $chatId');
      final response = await _apiClient.getMessages(
        chatId,
        limit: limit ?? defaultLimit,
        offset: offset ?? defaultOffset,
      );

      final messages = response.items
          .map((apiModel) => MessageTranslator().toDomain(apiModel))
          .toList();

      final paginatedResponse = PaginatedResponse<Message>(
        items: messages,
        offset: response.offset,
        limit: response.limit,
        total: response.total,
        hasMore: response.hasMore,
      );

      _log.info(
        'Successfully fetched ${messages.length}/${response.total} messages',
      );
      return Right(paginatedResponse);
    } on AppException catch (e) {
      _log.severe('AppException in getMessages: $e');
      return Left(FailureFactory.fromException(e));
    } catch (e) {
      _log.severe('Unexpected error in getMessages: $e');
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage({
    required String senderId,
    required String chatId,
    required String content,
    required MessageType type,
    String? replyToMessageId,
  }) async {
    try {
      _log.info('Sending message to chat: $chatId');
      final response = await _apiClient.sendMessage(
        senderId: senderId,
        chatId: chatId,
        content: content,
        type: type,
        replyToMessageId: replyToMessageId,
      );

      final message = MessageTranslator().toDomain(response);
      _log.info('Message sent successfully');
      return Right(message);
    } on AppException catch (e) {
      _log.severe('AppException in sendMessage: $e');
      return Left(FailureFactory.fromException(e));
    } catch (e) {
      _log.severe('Unexpected error in sendMessage: $e');
      return const Left(UnknownFailure());
    }
  }

  // WebSocket methods
  @override
  Future<void> joinChat(String chatId, String userId) async {
    await _webSocketService.joinChat(chatId, userId);
  }

  @override
  void leaveChat() {
    _webSocketService.leaveChat();
  }

  @override
  void sendTyping({required bool isTyping}) {
    _webSocketService.sendTyping(isTyping: isTyping);
  }

  @override
  Future<void> connectWebSocket() async {
    await _webSocketService.connect();
  }

  @override
  void disconnectWebSocket() {
    _webSocketService.disconnect();
  }
}
