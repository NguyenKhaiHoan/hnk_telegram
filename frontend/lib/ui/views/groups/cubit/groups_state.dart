part of 'groups_cubit.dart';

class GroupsState extends Equatable {
  const GroupsState({
    this.fetchMessagesStatus = FormzSubmissionStatus.initial,
    this.sendMessageStatus = FormzSubmissionStatus.initial,
    this.messages = const [],
    this.errorMessage,
    this.hasMoreMessages = true,
    this.isLoadingMore = false,
    this.oldestMessageTimestamp,
  });

  final FormzSubmissionStatus fetchMessagesStatus;
  final FormzSubmissionStatus sendMessageStatus;
  final List<Message> messages;
  final String? errorMessage;
  final bool hasMoreMessages;
  final bool isLoadingMore;
  final DateTime? oldestMessageTimestamp;

  GroupsState copyWith({
    FormzSubmissionStatus? fetchMessagesStatus,
    FormzSubmissionStatus? sendMessageStatus,
    List<Message>? messages,
    String? errorMessage,
    bool? hasMoreMessages,
    bool? isLoadingMore,
    DateTime? oldestMessageTimestamp,
  }) {
    return GroupsState(
      fetchMessagesStatus: fetchMessagesStatus ?? this.fetchMessagesStatus,
      sendMessageStatus: sendMessageStatus ?? this.sendMessageStatus,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      oldestMessageTimestamp:
          oldestMessageTimestamp ?? this.oldestMessageTimestamp,
    );
  }

  @override
  List<Object?> get props => [
        fetchMessagesStatus,
        sendMessageStatus,
        messages,
        errorMessage,
        hasMoreMessages,
        isLoadingMore,
        oldestMessageTimestamp,
      ];
}
