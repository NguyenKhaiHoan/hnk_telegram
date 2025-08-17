// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'story_api_model.freezed.dart';
part 'story_api_model.g.dart';

@freezed
abstract class StoryApiModel with _$StoryApiModel {
  const factory StoryApiModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'user_name') required String userName,
    @JsonKey(name: 'user_profile_picture') required String userProfilePicture,
    @JsonKey(name: 'story_picture') required String storyPicture,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'expires_at') required String expiresAt,
    String? caption,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'view_count') @Default(0) int viewCount,
  }) = _StoryApiModel;

  factory StoryApiModel.fromJson(Map<String, Object?> json) =>
      _$StoryApiModelFromJson(json);
}
