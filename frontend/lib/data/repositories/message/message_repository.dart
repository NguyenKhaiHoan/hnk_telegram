import 'package:dartz/dartz.dart';
import 'package:telegram_frontend/data/services/websocket_service.dart';
import 'package:telegram_frontend/domain/error/failure.dart';
import 'package:telegram_frontend/domain/models/message.dart';

abstract class MessageRepository {
  Future<Either<Failure, List<Message>>> getMessages(
    String chatId, {
    int? limit,
    int? offset,
  });

  Future<Either<Failure, Message>> sendMessage({
    required String senderId,
    required String chatId,
    required String content,
    required MessageType type,
    String? replyToMessageId,
  });

  Future<Either<Failure, void>> markMessageAsRead(String messageId);

  Stream<Message> get messageStream;
  Stream<TypingEvent> get typingStream;
  Stream<ConnectionStatus> get connectionStream;

  Future<void> joinChat(String chatId, String userId);
  void leaveChat();
  void sendTyping({required bool isTyping});
  Future<void> connectWebSocket();
  void disconnectWebSocket();
}
