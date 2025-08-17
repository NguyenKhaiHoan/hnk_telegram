// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'story.freezed.dart';
part 'story.g.dart';

@freezed
class Story with _$Story {
  const factory Story({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'user_name') required String userName,
    @JsonKey(name: 'user_profile_picture') required String userProfilePicture,
    @JsonKey(name: 'story_picture') required String storyPicture,
    String? caption,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'expires_at') required String expiresAt,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'view_count') @Default(0) int viewCount,
  }) = _Story;

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);
}
