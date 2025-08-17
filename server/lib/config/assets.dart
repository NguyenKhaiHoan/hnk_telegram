import 'dart:convert';
import 'dart:io';

import '../model/user/user.dart';
import '../model/chat/chat.dart';
import '../model/message/message.dart';
import '../model/story/story.dart';

abstract final class Assets {
  static const _users = 'assets/users.json';
  static const _chats = 'assets/chats.json';
  static const _messages = 'assets/messages.json';
  static const _stories = 'assets/stories.json';

  static List<User>? _usersList;
  static List<Chat>? _chatsList;
  static List<Message>? _messagesList;
  static List<Story>? _storiesList;

  static List<User> get users => _loadData<User>(
    _users,
    _usersList,
    (list) => _usersList = list,
    User.fromJson,
  );

  static List<Chat> get chats => _loadData<Chat>(
    _chats,
    _chatsList,
    (list) => _chatsList = list,
    Chat.fromJson,
  );

  static List<Message> get messages => _loadData<Message>(
    _messages,
    _messagesList,
    (list) => _messagesList = list,
    Message.fromJson,
  );

  static List<Story> get stories => _loadData<Story>(
    _stories,
    _storiesList,
    (list) => _storiesList = list,
    Story.fromJson,
  );

  static List<T> _loadData<T>(
    String filePath,
    List<T>? cachedList,
    void Function(List<T>) setCachedList,
    T Function(Map<String, Object?> json) fromJson,
  ) {
    if (cachedList != null) {
      return cachedList;
    }

    try {
      final currentDir = Directory.current.path;
      final fullPath = '$currentDir/$filePath';

      final file = File(fullPath);
      if (!file.existsSync()) {
        print('⚠️ Warning: File not found at $fullPath');
        final emptyList = <T>[];
        setCachedList(emptyList);
        return emptyList;
      }

      final jsonString = file.readAsStringSync();
      final jsonList = json.decode(jsonString) as List;

      final loadedList =
          jsonList
              .map((element) {
                try {
                  final data = element as Map<String, Object?>;
                  return fromJson(data);
                } catch (e) {
                  print('⚠️ Warning: Failed to parse element: $e');
                  return null;
                }
              })
              .whereType<T>()
              .toList();

      print('✅ Loaded ${loadedList.length} items from $filePath');
      setCachedList(loadedList);
      return loadedList;
    } catch (e) {
      print('❌ Error loading $filePath: $e');
      final emptyList = <T>[];
      setCachedList(emptyList);
      return emptyList;
    }
  }

  static Future<dynamic> loadJsonFile(String fileName) async {
    try {
      final currentDir = Directory.current.path;
      final fullPath = '$currentDir/assets/$fileName';

      final file = File(fullPath);
      if (!file.existsSync()) {
        print('⚠️ Warning: File not found at $fullPath');
        return [];
      }

      final jsonString = await file.readAsString();
      return json.decode(jsonString);
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveJsonFile(String fileName, dynamic data) async {
    try {
      final currentDir = Directory.current.path;
      final fullPath = '$currentDir/assets/$fileName';

      final file = File(fullPath);
      final jsonString = json.encode(
        data,
        toEncodable: (obj) {
          if (obj is DateTime) {
            return obj.toIso8601String();
          }
          return obj;
        },
      );

      await file.writeAsString(jsonString);
    } catch (e) {
      throw Exception('Failed to save file: $e');
    }
  }
}
