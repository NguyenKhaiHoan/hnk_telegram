// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@Freezed(fromJson: true, toJson: true)
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
    required String password,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'profile_picture') String? profilePicture,
    @JsonKey(name: 'is_online') @Default(0) int isOnline,
  }) = _User;

  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);
}
