import 'package:dio/dio.dart';
import 'package:telegram_frontend/data/services/api/base_dio_client.dart';
import 'package:telegram_frontend/data/services/api/model/chat/chat_api_model.dart';
import 'package:telegram_frontend/data/services/api/model/message/message_api_model.dart';
import 'package:telegram_frontend/data/services/api/model/story/story_api_model.dart';
import 'package:telegram_frontend/data/services/api/model/user/user_api_model.dart';
import 'package:telegram_frontend/domain/error/exception.dart';
import 'package:telegram_frontend/domain/models/message.dart';
import 'package:telegram_frontend/domain/models/paginated_response.dart';

class ApiClient extends BaseDioClient {
  ApiClient({
    super.baseUrl,
  });

  /// User
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

  /// Chat
  Future<PaginatedResponse<ChatApiModel>> getChats({
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response =
          await get<dynamic>('/chats', queryParameters: queryParams);

      if (response.data is Map<String, Object?>) {
        return PaginatedResponse<ChatApiModel>.fromJson(
          response.data as Map<String, Object?>,
          ChatApiModel.fromJson,
        );
      } else if (response.data is List<dynamic>) {
        final json = response.data as List<dynamic>;
        final chats = json
            .map(
              (chatJson) => ChatApiModel.fromJson(
                chatJson as Map<String, Object?>,
              ),
            )
            .toList();

        return PaginatedResponse<ChatApiModel>(
          items: chats,
          offset: 0,
          limit: chats.length,
          total: chats.length,
          hasMore: false,
        );
      } else {
        throw Exception(
          'Unexpected response format: ${response.data.runtimeType}',
        );
      }
    } on DioException catch (e) {
      throw ExceptionFactory.fromDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  /// Story
  Future<PaginatedResponse<StoryApiModel>> getActiveStories({
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await get<dynamic>(
        '/stories/active',
        queryParameters: queryParams,
      );

      if (response.data is Map<String, Object?>) {
        return PaginatedResponse<StoryApiModel>.fromJson(
          response.data as Map<String, Object?>,
          StoryApiModel.fromJson,
        );
      } else if (response.data is List<dynamic>) {
        final json = response.data as List<dynamic>;
        final stories = json
            .map(
              (storyJson) => StoryApiModel.fromJson(
                storyJson as Map<String, Object?>,
              ),
            )
            .toList();

        return PaginatedResponse<StoryApiModel>(
          items: stories,
          offset: 0,
          limit: stories.length,
          total: stories.length,
          hasMore: false,
        );
      } else {
        throw Exception(
          'Unexpected response format: ${response.data.runtimeType}',
        );
      }
    } on DioException catch (e) {
      throw ExceptionFactory.fromDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  /// Message
  Future<PaginatedResponse<MessageApiModel>> getMessages(
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

      if (response.data is Map<String, Object?>) {
        return PaginatedResponse<MessageApiModel>.fromJson(
          response.data as Map<String, Object?>,
          MessageApiModel.fromJson,
        );
      } else if (response.data is List<dynamic>) {
        final json = response.data as List<dynamic>;
        final messages = json
            .map(
              (messageJson) => MessageApiModel.fromJson(
                messageJson as Map<String, Object?>,
              ),
            )
            .toList();

        return PaginatedResponse<MessageApiModel>(
          items: messages,
          offset: 0,
          limit: messages.length,
          total: messages.length,
          hasMore: false,
        );
      } else {
        throw Exception(
          'Unexpected response format: ${response.data.runtimeType}',
        );
      }
    } on DioException catch (e) {
      throw ExceptionFactory.fromDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<MessageApiModel> sendMessage({
    required String senderId,
    required String chatId,
    required String content,
    required MessageType type,
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

      return MessageApiModel.fromJson(
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

  String _mapMessageTypeToString(MessageType type) {
    switch (type) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.file:
        return 'file';
      case MessageType.location:
        return 'location';
      case MessageType.link:
        return 'link';
    }
  }
}
