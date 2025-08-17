import 'package:telegram_frontend/data/services/api/model/chat/chat_api_model.dart';
import 'package:telegram_frontend/domain/models/chat.dart';

class ChatTranslator {
  Chat toDomain(ChatApiModel model) {
    return Chat(
      id: model.id,
      name: model.name,
      profilePicture: model.profilePicture,
      type: model.type,
      lastMessage: model.lastMessage,
      lastMessageTime: DateTime.parse(model.lastMessageTime),
      unreadCount: model.unreadCount,
      isMuted: model.isMuted,
      isOnline: model.isOnline,
      isVerified: model.isVerified,
      status: model.status,
      badge: model.badge,
    );
  }
}
