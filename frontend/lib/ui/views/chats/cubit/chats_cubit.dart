import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

import 'package:telegram_frontend/data/repositories/chat/chat_repository.dart';
import 'package:telegram_frontend/data/repositories/story/story_repository.dart';
import 'package:telegram_frontend/data/services/api/model/chat/chat_api_model.dart';
import 'package:telegram_frontend/domain/models/chat.dart';
import 'package:telegram_frontend/domain/models/story.dart';
import 'package:telegram_frontend/ui/core/cubit/base_cubit.dart';
import 'package:telegram_frontend/ui/views/nav/cubit/nav_cubit.dart';

part 'chats_state.dart';

class ChatsCubit extends BaseCubit<ChatsState> {
  ChatsCubit({
    required NavCubit navCubit,
    required ChatRepository chatRepository,
    required StoryRepository storyRepository,
  })  : _navCubit = navCubit,
        _chatRepository = chatRepository,
        _storyRepository = storyRepository,
        super(const ChatsState());

  final NavCubit _navCubit;
  final ChatRepository _chatRepository;
  final StoryRepository _storyRepository;

  String? get userId => _navCubit.state.user?.id;

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
      final result = await _chatRepository.getPaginated(null);

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              fetchChatListStatus: FormzSubmissionStatus.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (paginatedResponse) {
          emit(
            state.copyWith(
              fetchChatListStatus: FormzSubmissionStatus.success,
              chats: paginatedResponse.items,
              unreadCounts: _calculateUnreadCounts(paginatedResponse.items),
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
      final result = await _storyRepository.getPaginated(null);

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              fetchStoriesStatus: FormzSubmissionStatus.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (paginatedResponse) {
          final userStory = paginatedResponse.items
              .where((s) => s.userId == userId)
              .firstOrNull;

          final newStories = List<Story>.from(paginatedResponse.items);

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
