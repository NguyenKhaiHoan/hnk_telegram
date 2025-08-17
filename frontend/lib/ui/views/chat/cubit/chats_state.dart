part of 'chats_cubit.dart';

class ChatsState extends Equatable {
  const ChatsState({
    this.chats = const [],
    this.stories = const [],
    this.unreadCounts = const {},
    this.seenTabs = const {},
    this.fetchChatListStatus = FormzSubmissionStatus.initial,
    this.fetchStoriesStatus = FormzSubmissionStatus.initial,
    this.errorMessage,
  });

  final List<Chat> chats;
  final List<Story> stories;
  final Map<ChatType, int> unreadCounts;
  final Set<ChatType> seenTabs;
  final FormzSubmissionStatus fetchChatListStatus;
  final FormzSubmissionStatus fetchStoriesStatus;
  final String? errorMessage;

  bool hasNewFor(ChatType type) {
    final count = unreadCounts[type] ?? 0;
    return count > 0 && !seenTabs.contains(type);
  }

  ChatsState copyWith({
    List<Chat>? chats,
    List<Story>? stories,
    Map<ChatType, int>? unreadCounts,
    Set<ChatType>? seenTabs,
    FormzSubmissionStatus? fetchChatListStatus,
    FormzSubmissionStatus? fetchStoriesStatus,
    String? errorMessage,
  }) {
    return ChatsState(
      chats: chats ?? this.chats,
      stories: stories ?? this.stories,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      seenTabs: seenTabs ?? this.seenTabs,
      fetchChatListStatus: fetchChatListStatus ?? this.fetchChatListStatus,
      fetchStoriesStatus: fetchStoriesStatus ?? this.fetchStoriesStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        chats,
        stories,
        unreadCounts,
        seenTabs,
        fetchChatListStatus,
        fetchStoriesStatus,
        errorMessage,
      ];
}
