import 'package:dartz/dartz.dart';
import 'package:telegram_frontend/data/repositories/story/story_repository.dart';

import 'package:telegram_frontend/domain/error/failure.dart';
import 'package:telegram_frontend/domain/models/story.dart';

class StoryRepositoryLocal implements StoryRepository {
  @override
  Future<Either<Failure, List<Story>>> getActiveStories() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Story>> getStory(String storyId) {
    throw UnimplementedError();
  }
}
