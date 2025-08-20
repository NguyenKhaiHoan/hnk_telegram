import 'package:telegram_frontend/data/services/api/model/message/message_api_model.dart';

class MessagesResponse {
  const MessagesResponse({
    required this.messages,
    required this.hasMore,
    required this.chatId,
    required this.limit,
    required this.offset,
    required this.total,
  });

  final List<MessageApiModel> messages;
  final bool hasMore;
  final String chatId;
  final int limit;
  final int offset;
  final int total;
}
