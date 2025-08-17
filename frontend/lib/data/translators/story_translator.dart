import 'package:telegram_frontend/data/services/api/model/story/story_api_model.dart';
import 'package:telegram_frontend/domain/models/story.dart';

class StoryTranslator {
  Story toDomain(StoryApiModel model) {
    return Story(
      id: model.id,
      userId: model.userId,
      userName: model.userName,
      userProfilePicture: model.userProfilePicture,
      storyPicture: model.storyPicture,
      caption: model.caption,
      createdAt: DateTime.parse(model.createdAt),
      expiresAt: DateTime.parse(model.expiresAt),
      isActive: model.isActive,
      viewCount: model.viewCount,
    );
  }
}
