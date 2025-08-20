import 'package:dio/dio.dart';
import 'package:telegram_frontend/data/services/api/base_dio_client.dart';
import 'package:telegram_frontend/data/services/api/model/message/messages_response.dart';
import 'package:telegram_frontend/data/services/api/model/chat/chat_api_model.dart';
import 'package:telegram_frontend/data/services/api/model/message/message_api_model.dart'
    as api;
import 'package:telegram_frontend/data/services/api/model/story/story_api_model.dart';
import 'package:telegram_frontend/data/services/api/model/user/user_api_model.dart';
import 'package:telegram_frontend/domain/error/exception.dart';
import 'package:telegram_frontend/domain/models/message.dart' as domain;

class ApiClient extends BaseDioClient {
  ApiClient({
    super.baseUrl,
  });

  Future<List<UserApiModel>> getUsers() async {
    try {
      final response = await get<dynamic>('/users');
      final json = response.data as List<dynamic>;
      return json
          .map(
            (userJson) => UserApiModel.fromJson(
              userJson as Map<String, Object?>,
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw ExceptionFactory.fromDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserApiModel> getUser(String id) async {
    try {
      final response = await get<dynamic>('/users/$id');
      return UserApiModel.fromJson(
        response.data as Map<String, Object?>,
      );
    } on DioException catch (e) {
      throw ExceptionFactory.fromDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ChatApiModel>> getChats() async {
    try {
      final response = await get<dynamic>('/chats');
      final json = response.data as List<dynamic>;
      return json
          .map(
            (chatJson) => ChatApiModel.fromJson(
              chatJson as Map<String, Object?>,
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw ExceptionFactory.fromDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<ChatApiModel> getChat(String id) async {
    try {
      final response = await get<dynamic>('/chats/$id');
      return ChatApiModel.fromJson(
        response.data as Map<String, Object?>,
      );
    } on DioException catch (e) {
      throw ExceptionFactory.fromDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<StoryApiModel>> getActiveStories() async {
    try {
      final response = await get<dynamic>('/stories/active');
      final json = response.data as List<dynamic>;
      return json
          .map(
            (storyJson) => StoryApiModel.fromJson(
              storyJson as Map<String, Object?>,
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw ExceptionFactory.fromDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  /// Get story by ID
  Future<StoryApiModel> getStory(String id) async {
    try {
      final response = await get<dynamic>('/stories/$id');
      return StoryApiModel.fromJson(
        response.data as Map<String, Object?>,
      );
    } on DioException catch (e) {
      throw ExceptionFactory.fromDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  /// Message
  Future<MessagesResponse> getMessages(
    String chatId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await get<dynamic>(
        '/messages/chat/$chatId',
        queryParameters: queryParams,
      );

      final json = response.data as Map<String, dynamic>;
      final messagesJson = json['messages'] as List<dynamic>;

      final messages = messagesJson
          .map(
            (messageJson) => api.MessageApiModel.fromJson(
              messageJson as Map<String, Object?>,
            ),
          )
          .toList();

      return MessagesResponse(
        messages: messages,
        hasMore: json['hasMore'] as bool? ?? false,
        chatId: json['chatId'] as String,
        limit: json['limit'] as int? ?? 10,
        offset: json['offset'] as int? ?? 0,
        total: json['total'] as int? ?? 0,
      );
    } on DioException catch (e) {
      throw ExceptionFactory.fromDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<api.MessageApiModel> sendMessage({
    required String senderId,
    required String chatId,
    required String content,
    required domain.MessageType type,
    String? replyToMessageId,
  }) async {
    try {
      final data = {
        'chat_id': chatId,
        'sender_id': senderId,
        'content': content,
        'type': _mapMessageTypeToString(type),
        'status': 'sent',
        'reply_to_message_id': replyToMessageId,
      };

      final response = await post<dynamic>('/messages', data: data);

      return api.MessageApiModel.fromJson(
        response.data as Map<String, Object?>,
      );
    } on DioException catch (e) {
      throw ExceptionFactory.fromDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markMessageAsRead(String messageId) async {
    try {
      await put<dynamic>('/messages/$messageId/read');
    } on DioException catch (e) {
      throw ExceptionFactory.fromDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  String _mapMessageTypeToString(domain.MessageType type) {
    switch (type) {
      case domain.MessageType.text:
        return 'text';
      case domain.MessageType.image:
        return 'image';
      case domain.MessageType.file:
        return 'file';
      case domain.MessageType.location:
        return 'location';
      case domain.MessageType.link:
        return 'link';
    }
  }
}
