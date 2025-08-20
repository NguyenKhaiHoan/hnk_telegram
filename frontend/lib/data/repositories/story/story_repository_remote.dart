import 'package:dartz/dartz.dart';
import 'package:logging/logging.dart';
import 'package:telegram_frontend/data/repositories/story/story_repository.dart';
import 'package:telegram_frontend/data/services/api/api_client.dart';
import 'package:telegram_frontend/data/translators/story_translator.dart';
import 'package:telegram_frontend/domain/error/exception.dart';
import 'package:telegram_frontend/domain/error/failure.dart';
import 'package:telegram_frontend/domain/models/paginated_response.dart';
import 'package:telegram_frontend/domain/models/story.dart';
import 'package:telegram_frontend/utils/constant.dart';

class StoryRepositoryRemote implements StoryRepository {
  StoryRepositoryRemote({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;
  final _log = Logger('StoryRepositoryRemote');

  @override
  Future<Either<Failure, PaginatedResponse<Story>>> getPaginated(
    dynamic params, {
    int? limit,
    int? offset,
  }) async {
    try {
      _log.info('Fetching stories...');
      final response = await _apiClient.getActiveStories(
        limit: limit ?? defaultLimit,
        offset: offset ?? defaultOffset,
      );
      final stories = response.items
          .map((apiModel) => StoryTranslator().toDomain(apiModel))
          .toList();

      final paginatedResponse = PaginatedResponse<Story>(
        items: stories,
        offset: response.offset,
        limit: response.limit,
        total: response.total,
        hasMore: response.hasMore,
      );

      _log.info('Successfully fetched ${stories.length} stories');
      return Right(paginatedResponse);
    } on AppException catch (e) {
      _log.severe('AppException in getStories: $e');
      return Left(FailureFactory.fromException(e));
    } catch (e) {
      _log.severe('Unexpected error in getStories: $e');
      return const Left(UnknownFailure());
    }
  }
}
