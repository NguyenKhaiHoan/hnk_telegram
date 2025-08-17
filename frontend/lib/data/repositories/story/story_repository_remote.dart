import 'package:dartz/dartz.dart';
import 'package:logging/logging.dart';
import 'package:telegram_frontend/data/repositories/story/story_repository.dart';
import 'package:telegram_frontend/data/services/api/api_client.dart';
import 'package:telegram_frontend/data/translators/story_translator.dart';
import 'package:telegram_frontend/domain/error/exception.dart';
import 'package:telegram_frontend/domain/error/failure.dart';
import 'package:telegram_frontend/domain/models/story.dart';

class StoryRepositoryRemote implements StoryRepository {
  StoryRepositoryRemote({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;
  final _log = Logger('StoryRepositoryRemote');

  @override
  Future<Either<Failure, List<Story>>> getActiveStories() async {
    try {
      _log.info('Fetching stories...');
      final storyApiModels = await _apiClient.getActiveStories();
      final stories = storyApiModels
          .map((apiModel) => StoryTranslator().toDomain(apiModel))
          .toList();

      _log.info('Successfully fetched ${stories.length} stories');
      return Right(stories);
    } on AppException catch (e) {
      _log.severe('AppException in getStories: $e');
      return Left(FailureFactory.fromException(e));
    } catch (e) {
      _log.severe('Unexpected error in getStories: $e');
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Story>> getStory(String storyId) async {
    try {
      final storyApiModel = await _apiClient.getStory(storyId);
      final story = StoryTranslator().toDomain(storyApiModel);
      return Right(story);
    } on AppException catch (e) {
      _log.severe('AppException in getStory: $e');
      return Left(FailureFactory.fromException(e));
    } catch (e) {
      _log.severe('Unexpected error in getStory: $e');
      return const Left(UnknownFailure());
    }
  }
}
