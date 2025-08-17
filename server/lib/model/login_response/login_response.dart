// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_response.freezed.dart';
part 'login_response.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class LoginResponse with _$LoginResponse {
  const factory LoginResponse({required String token, required UserData user}) =
      _LoginResponse;

  factory LoginResponse.fromJson(Map<String, Object?> json) =>
      _$LoginResponseFromJson(json);
}

@Freezed(fromJson: true, toJson: true)
abstract class UserData with _$UserData {
  const factory UserData({
    required String id,
    required String name,
    required String email,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'profile_picture') String? profilePicture,
    @JsonKey(name: 'is_online') @Default(0) int isOnline,
  }) = _UserData;

  factory UserData.fromJson(Map<String, Object?> json) =>
      _$UserDataFromJson(json);
}
