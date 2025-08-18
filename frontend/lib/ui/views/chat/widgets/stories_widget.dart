import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:telegram_frontend/domain/models/story.dart';
import 'package:telegram_frontend/ui/views/chat/cubit/chats_cubit.dart';
import 'package:telegram_frontend/ui/views/chat/widgets/story_item_widget.dart';

class StoriesWidget extends StatelessWidget {
  const StoriesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ChatsCubit, ChatsState, List<Story>>(
      selector: (state) {
        return state.stories;
      },
      builder: (context, stories) {
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          itemCount: stories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final story = stories[index];
            return StoryItemWidget(
              userProfilePicture: story.userProfilePicture,
              userName: story.userName,
              isActive: story.isActive,
              isSeen: false,
              isCurrentUserStory: story.isCurrentUserStory,
            );
          },
        );
      },
    );
  }
}
