import 'package:telegram_frontend/data/services/api/model/chat/chat_api_model.dart';

class Chat {
  Chat({
    required this.id,
    required this.name,
    required this.profilePicture,
    required this.type,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isMuted,
    required this.isOnline,
    required this.isVerified,
    this.status,
    this.badge,
  });

  final String id;
  final String name;
  final String profilePicture;
  final ChatType type;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isMuted;
  final bool isOnline;
  final bool isVerified;
  final String? status;
  final int? badge;
}
