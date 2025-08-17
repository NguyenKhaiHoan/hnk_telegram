// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_api_model.freezed.dart';
part 'chat_api_model.g.dart';

enum ChatType {
  @JsonValue('direct')
  direct,
  @JsonValue('group')
  group,
  @JsonValue('channel')
  channel,
  @JsonValue('bot')
  bot
}

@freezed
abstract class ChatApiModel with _$ChatApiModel {
  const factory ChatApiModel({
    required String id,
    required String name,
    @JsonKey(name: 'profile_picture') required String profilePicture,
    required ChatType type,
    @JsonKey(name: 'last_message') required String lastMessage,
    @JsonKey(name: 'last_message_time') required String lastMessageTime,
    @JsonKey(name: 'unread_count') required int unreadCount,
    @JsonKey(name: 'is_muted') required bool isMuted,
    @JsonKey(name: 'is_online') required bool isOnline,
    @JsonKey(name: 'is_verified') required bool isVerified,
    String? status,
    int? badge, // Changed from String? to int? to match server
  }) = _ChatApiModel;

  factory ChatApiModel.fromJson(Map<String, Object?> json) =>
      _$ChatApiModelFromJson(json);
}
