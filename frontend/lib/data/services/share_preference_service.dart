import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:telegram_frontend/domain/models/user.dart';

class SharedPreferencesService {
  static const _tokenKey = 'TOKEN';
  static const _userKey = 'USER';

  Future<String?> fetchToken() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(_tokenKey);
  }

  Future<void> saveToken(String? token) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    if (token == null) {
      await sharedPreferences.remove(_tokenKey);
    } else {
      await sharedPreferences.setString(_tokenKey, token);
    }
  }

  Future<User?> fetchUser() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final userJson = sharedPreferences.getString(_userKey);

    if (userJson == null) {
      return null;
    }

    final userMap = json.decode(userJson) as Map<String, dynamic>;
    final user = User.fromJson(userMap);

    return user;
  }

  Future<void> saveUser(User user) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final userJson = json.encode(user.toJson());

    await sharedPreferences.setString(_userKey, userJson);
  }

  Future<void> clearUser() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove(_userKey);
    await saveToken(null);
  }
}
