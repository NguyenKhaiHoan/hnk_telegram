// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

enum MessageType {
  @JsonValue('text')
  text,
  @JsonValue('image')
  image,
  @JsonValue('video')
  video,
  @JsonValue('audio')
  audio,
  @JsonValue('file')
  file,
  @JsonValue('voice')
  voice,
  @JsonValue('sticker')
  sticker,
  @JsonValue('link')
  link,
  @JsonValue('location')
  location,
  @JsonValue('contact')
  contact,
  @JsonValue('poll')
  poll,
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

@Freezed(fromJson: true, toJson: true)
abstract class LinkPreview with _$LinkPreview {
  const factory LinkPreview({
    required String url,
    required String title,
    String? description,
    String? thumbnail,
    @JsonKey(name: 'site_name') String? siteName,
    String? type, // youtube, website, etc.
  }) = _LinkPreview;

  factory LinkPreview.fromJson(Map<String, Object?> json) =>
      _$LinkPreviewFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
abstract class Location with _$Location {
  const factory Location({
    required double latitude,
    required double longitude,
    @JsonKey(name: 'place_name') String? placeName,
    @JsonKey(name: 'shared_at') String? sharedAt,
  }) = _Location;

  factory Location.fromJson(Map<String, Object?> json) =>
      _$LocationFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
abstract class FileInfo with _$FileInfo {
  const factory FileInfo({
    @JsonKey(name: 'file_name') required String fileName,
    @JsonKey(name: 'file_path') required String filePath,
    @JsonKey(name: 'file_size') required int fileSize, // bytes
    @JsonKey(name: 'mime_type') required String mimeType,
    String? thumbnail,
    @JsonKey(name: 'is_downloaded') @Default(false) bool isDownloaded,
    @JsonKey(name: 'download_progress')
    @Default(0)
    int downloadProgress, // 0-100
  }) = _FileInfo;

  factory FileInfo.fromJson(Map<String, Object?> json) =>
      _$FileInfoFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
abstract class Message with _$Message {
  const factory Message({
    required String id,
    @JsonKey(name: 'chat_id') required String chatId,
    @JsonKey(name: 'sender_id') required String senderId,
    required String content,
    required MessageType type,
    required MessageStatus status,
    required String timestamp,
    @JsonKey(name: 'reply_to_message_id') String? replyToMessageId,
    @JsonKey(name: 'link_preview') LinkPreview? linkPreview,
    @JsonKey(name: 'location') Location? location,
    @JsonKey(name: 'file_info') FileInfo? fileInfo,
    Map<String, dynamic>? metadata,
    @JsonKey(name: 'is_edited') @Default(false) bool isEdited,
    @JsonKey(name: 'edited_at') String? editedAt,
    @JsonKey(name: 'is_deleted') @Default(false) bool isDeleted,
    @JsonKey(name: 'deleted_at') String? deletedAt,
    @JsonKey(name: 'forwarded_from_chat_id') String? forwardedFromChatId,
    @JsonKey(name: 'forwarded_from_message_id') String? forwardedFromMessageId,
    @JsonKey(name: 'reply_to_message_ids') List<String>? replyToMessageIds,
    @JsonKey(name: 'reactions') Map<String, List<String>>? reactions,
    @JsonKey(name: 'viewed_by') List<String>? viewedBy,
    @JsonKey(name: 'view_count') int? viewCount,
  }) = _Message;

  factory Message.fromJson(Map<String, Object?> json) =>
      _$MessageFromJson(json);
}
