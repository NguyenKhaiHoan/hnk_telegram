// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_api_model.freezed.dart';
part 'message_api_model.g.dart';

enum MessageTypeApi {
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

enum MessageStatusApi {
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

// Sender info from API
@freezed
abstract class MessageSenderApi with _$MessageSenderApi {
  const factory MessageSenderApi({
    required String id,
    required String name,
    @JsonKey(name: 'profile_picture') String? profilePicture,
  }) = _MessageSenderApi;

  factory MessageSenderApi.fromJson(Map<String, Object?> json) =>
      _$MessageSenderApiFromJson(json);
}

// Location data from API
@freezed
abstract class MessageLocationApi with _$MessageLocationApi {
  const factory MessageLocationApi({
    required double latitude,
    required double longitude,
    String? address,
  }) = _MessageLocationApi;

  factory MessageLocationApi.fromJson(Map<String, Object?> json) =>
      _$MessageLocationApiFromJson(json);
}

// Link preview from API
@freezed
abstract class MessageLinkPreviewApi with _$MessageLinkPreviewApi {
  const factory MessageLinkPreviewApi({
    required String url,
    required String title,
    String? description,
    @JsonKey(name: 'image_url') String? imageUrl,
  }) = _MessageLinkPreviewApi;

  factory MessageLinkPreviewApi.fromJson(Map<String, Object?> json) =>
      _$MessageLinkPreviewApiFromJson(json);
}

// File info from API
@freezed
abstract class MessageFileInfoApi with _$MessageFileInfoApi {
  const factory MessageFileInfoApi({
    @JsonKey(name: 'file_name') required String fileName,
    @JsonKey(name: 'file_url') required String fileUrl,
    @JsonKey(name: 'file_size') required int fileSize,
    @JsonKey(name: 'mime_type') String? mimeType,
  }) = _MessageFileInfoApi;

  factory MessageFileInfoApi.fromJson(Map<String, Object?> json) =>
      _$MessageFileInfoApiFromJson(json);
}

// Main Message API model - matches server response
@freezed
abstract class MessageApiModel with _$MessageApiModel {
  const factory MessageApiModel({
    required String id,
    @JsonKey(name: 'chat_id') required String chatId,
    required MessageSenderApi sender,
    required String content,
    required MessageTypeApi type,
    required MessageStatusApi status,
    required String timestamp,
    @JsonKey(name: 'reply_to_message_id') String? replyToMessageId,
    MessageLocationApi? location,
    @JsonKey(name: 'link_preview') MessageLinkPreviewApi? linkPreview,
    @JsonKey(name: 'file_info') MessageFileInfoApi? fileInfo,
  }) = _MessageApiModel;

  factory MessageApiModel.fromJson(Map<String, Object?> json) =>
      _$MessageApiModelFromJson(json);
}
