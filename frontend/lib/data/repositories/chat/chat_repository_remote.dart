import 'package:dartz/dartz.dart';
import 'package:logging/logging.dart';

import 'package:telegram_frontend/data/repositories/chat/chat_repository.dart';
import 'package:telegram_frontend/data/services/api/api_client.dart';
import 'package:telegram_frontend/data/translators/chat_translator.dart';
import 'package:telegram_frontend/domain/error/exception.dart';
import 'package:telegram_frontend/domain/error/failure.dart';
import 'package:telegram_frontend/domain/models/chat.dart';
import 'package:telegram_frontend/domain/models/paginated_response.dart';
import 'package:telegram_frontend/utils/constant.dart';

class ChatRepositoryRemote extends ChatRepository {
  ChatRepositoryRemote({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;
  final _log = Logger('ChatRepositoryRemote');

  @override
  Future<Either<Failure, PaginatedResponse<Chat>>> getPaginated(
    dynamic params, {
    int? limit,
    int? offset,
  }) async {
    try {
      _log.info('Fetching chats...');
      final response = await _apiClient.getChats(
        limit: limit ?? defaultLimit,
        offset: offset ?? defaultOffset,
      );

      final chats = response.items
          .map((apiModel) => ChatTranslator().toDomain(apiModel))
          .toList();

      final paginatedResponse = PaginatedResponse<Chat>(
        items: chats,
        offset: response.offset,
        limit: response.limit,
        total: response.total,
        hasMore: response.hasMore,
      );

      _log.info('Successfully fetched ${chats.length}/${response.total} chats');
      return Right(paginatedResponse);
    } on AppException catch (e) {
      _log.severe('AppException in getChats: $e');
      return Left(FailureFactory.fromException(e));
    } catch (e) {
      _log.severe('Unexpected error in getChats: $e');
      return const Left(UnknownFailure());
    }
  }
}
