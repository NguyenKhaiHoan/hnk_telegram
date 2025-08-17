import 'package:dio/dio.dart';
import 'package:telegram_frontend/data/services/api/base_dio_client.dart';
import 'package:telegram_frontend/data/services/api/model/chat/chat_api_model.dart';
import 'package:telegram_frontend/data/services/api/model/story/story_api_model.dart';
import 'package:telegram_frontend/data/services/api/model/user/user_api_model.dart';
import 'package:telegram_frontend/domain/error/exception.dart';

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
}
