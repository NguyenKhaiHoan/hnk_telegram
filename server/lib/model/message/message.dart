// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

enum MessageType {
  @JsonValue('text')
  text,
  @JsonValue('image')
  image,
  @JsonValue('file')
  file,
  @JsonValue('location')
  location,
  @JsonValue('link')
  link,
}

enum MessageStatus {
  @JsonValue('sending')
  sending,
  @JsonValue('sent')
  sent,
  @JsonValue('delivered')
  delivered,
  @JsonValue('read')
  read,
  @JsonValue('failed')
  failed,
}

// User information in message
@Freezed(fromJson: true, toJson: true)
abstract class MessageSender with _$MessageSender {
  const factory MessageSender({
    required String id,
    required String name,
    @JsonKey(name: 'profile_picture') String? profilePicture,
  }) = _MessageSender;

  factory MessageSender.fromJson(Map<String, Object?> json) =>
      _$MessageSenderFromJson(json);
}

// Location data for location messages
@Freezed(fromJson: true, toJson: true)
abstract class MessageLocation with _$MessageLocation {
  const factory MessageLocation({
    required double latitude,
    required double longitude,
    String? address,
  }) = _MessageLocation;

  factory MessageLocation.fromJson(Map<String, Object?> json) =>
      _$MessageLocationFromJson(json);
}

// Link preview for link messages
@Freezed(fromJson: true, toJson: true)
abstract class MessageLinkPreview with _$MessageLinkPreview {
  const factory MessageLinkPreview({
    required String url,
    required String title,
    String? description,
    @JsonKey(name: 'image_url') String? imageUrl,
  }) = _MessageLinkPreview;

  factory MessageLinkPreview.fromJson(Map<String, Object?> json) =>
      _$MessageLinkPreviewFromJson(json);
}

// File info for file messages
@Freezed(fromJson: true, toJson: true)
abstract class MessageFileInfo with _$MessageFileInfo {
  const factory MessageFileInfo({
    @JsonKey(name: 'file_name') required String fileName,
    @JsonKey(name: 'file_url') required String fileUrl,
    @JsonKey(name: 'file_size') required int fileSize,
    @JsonKey(name: 'mime_type') String? mimeType,
  }) = _MessageFileInfo;

  factory MessageFileInfo.fromJson(Map<String, Object?> json) =>
      _$MessageFileInfoFromJson(json);
}

// Main Message class - simplified and clean
@Freezed(fromJson: true, toJson: true)
abstract class Message with _$Message {
  const factory Message({
    required String id,
    @JsonKey(name: 'chat_id') required String chatId,
    required MessageSender sender,
    required String content,
    required MessageType type,
    required MessageStatus status,
    required String timestamp,
    @JsonKey(name: 'reply_to_message_id') String? replyToMessageId,
    MessageLocation? location,
    @JsonKey(name: 'link_preview') MessageLinkPreview? linkPreview,
    @JsonKey(name: 'file_info') MessageFileInfo? fileInfo,
  }) = _Message;

  factory Message.fromJson(Map<String, Object?> json) =>
      _$MessageFromJson(json);
}
