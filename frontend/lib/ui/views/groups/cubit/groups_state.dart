part of 'groups_cubit.dart';

class GroupsState extends Equatable {
  const GroupsState({
    this.fetchMessagesStatus = FormzSubmissionStatus.initial,
    this.sendMessageStatus = FormzSubmissionStatus.initial,
    this.messages = const [],
    this.errorMessage,
  });

  final FormzSubmissionStatus fetchMessagesStatus;
  final FormzSubmissionStatus sendMessageStatus;
  final List<Message> messages;
  final String? errorMessage;

  GroupsState copyWith({
    FormzSubmissionStatus? fetchMessagesStatus,
    FormzSubmissionStatus? sendMessageStatus,
    List<Message>? messages,
    String? errorMessage,
  }) {
    return GroupsState(
      fetchMessagesStatus: fetchMessagesStatus ?? this.fetchMessagesStatus,
      sendMessageStatus: sendMessageStatus ?? this.sendMessageStatus,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        fetchMessagesStatus,
        sendMessageStatus,
        messages,
        errorMessage,
      ];
}
