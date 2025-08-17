import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import 'package:telegram_frontend/data/repositories/chat/chat_repository.dart';
import 'package:telegram_frontend/data/repositories/story/story_repository.dart';
import 'package:telegram_frontend/data/services/api/model/chat/chat_api_model.dart';
import 'package:telegram_frontend/domain/models/chat.dart';
import 'package:telegram_frontend/domain/models/story.dart';
import 'package:telegram_frontend/ui/views/nav/cubit/nav_cubit.dart';

part 'chats_state.dart';

class ChatsCubit extends Cubit<ChatsState> {
  ChatsCubit({
    required NavCubit homeCubit,
    required ChatRepository chatRepository,
    required StoryRepository storyRepository,
  })  : _homeCubit = homeCubit,
        _chatRepository = chatRepository,
        _storyRepository = storyRepository,
        super(const ChatsState());

  final NavCubit _homeCubit;
  final ChatRepository _chatRepository;
  final StoryRepository _storyRepository;

  String? get userId => _homeCubit.state.user?.id;

  void initialize() {
    loadChats();
    loadStories();
  }

  void markTabAsSeen(ChatType type) {
    final newSeen = Set<ChatType>.from(state.seenTabs)..add(type);
    emit(state.copyWith(seenTabs: newSeen));
  }

  Future<void> loadChats() async {
    emit(state.copyWith(fetchChatListStatus: FormzSubmissionStatus.inProgress));

    try {
      final result = await _chatRepository.getChats();

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              fetchChatListStatus: FormzSubmissionStatus.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (chats) {
          emit(
            state.copyWith(
              fetchChatListStatus: FormzSubmissionStatus.success,
              chats: chats,
              unreadCounts: _calculateUnreadCounts(chats),
            ),
          );
        },
      );
    } catch (error) {
      emit(
        state.copyWith(
          fetchChatListStatus: FormzSubmissionStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Map<ChatType, int> _calculateUnreadCounts(List<Chat> chats) {
    final counts = <ChatType, int>{};
    for (final chat in chats) {
      counts[chat.type] = (counts[chat.type] ?? 0) + chat.unreadCount;
    }
    return counts;
  }

  Future<void> loadStories() async {
    emit(state.copyWith(fetchStoriesStatus: FormzSubmissionStatus.inProgress));

    try {
      final result = await _storyRepository.getActiveStories();

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              fetchStoriesStatus: FormzSubmissionStatus.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (stories) {
          final userStory =
              stories.where((s) => s.userId == userId).firstOrNull;

          final newStories = List<Story>.from(stories);

          if (userStory != null) {
            newStories
              ..removeWhere((s) => s.userId == userId)
              ..insert(0, userStory.copyWith(isCurrentUserStory: true));
          }

          emit(
            state.copyWith(
              fetchStoriesStatus: FormzSubmissionStatus.success,
              stories: newStories,
            ),
          );
        },
      );
    } catch (error) {
      emit(
        state.copyWith(
          fetchStoriesStatus: FormzSubmissionStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
