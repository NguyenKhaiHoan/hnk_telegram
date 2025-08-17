import 'package:dartz/dartz.dart';

import 'package:telegram_frontend/domain/error/failure.dart';
import 'package:telegram_frontend/domain/models/story.dart';

abstract class StoryRepository {
  Future<Either<Failure, List<Story>>> getActiveStories();

  Future<Either<Failure, Story>> getStory(String storyId);
}
