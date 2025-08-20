import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:logging/logging.dart';

import 'package:telegram_frontend/data/repositories/message/message_repository.dart';
import 'package:telegram_frontend/domain/models/message.dart';
import 'package:telegram_frontend/ui/core/cubit/base_cubit.dart';
import 'package:telegram_frontend/ui/views/nav/cubit/nav_cubit.dart';

part 'groups_state.dart';

class GroupsCubit extends BaseCubit<GroupsState> {
  GroupsCubit({
    required MessageRepository messageRepository,
    required NavCubit navCubit,
  })  : _messageRepository = messageRepository,
        _navCubit = navCubit,
        super(const GroupsState());

  final NavCubit _navCubit;
  final MessageRepository _messageRepository;
  String? _currentChatId;
  final _log = Logger('GroupsCubit');

  void initialize(String chatId) {
    _currentChatId = chatId;

    // Setup WebSocket connection
    _setupWebSocket(chatId);
    loadMessages();
  }

  Future<void> _setupWebSocket(String chatId) async {
    final user = _navCubit.state.user;
    if (user == null) return;

    try {
      // Connect to WebSocket and join chat
      await _messageRepository.connectWebSocket();
      await _messageRepository.joinChat(chatId, user.id);

      // Listen for new messages
      _messageRepository.messageStream.listen((newMessage) {
        if (!isClosed && newMessage.chatId == _currentChatId) {
          _addNewMessage(newMessage);
        }
      });

      // Listen for typing events
      _messageRepository.typingStream.listen((typingEvent) {
        // Handle typing indicators if needed
        _log.info(
          '👀 Typing event: ${typingEvent.userId} - ${typingEvent.isTyping}',
        );
      });
    } catch (e) {
      _log.severe('❌ Failed to setup WebSocket: $e');
    }
  }

  void _addNewMessage(Message newMessage) {
    final user = _navCubit.state.user;
    if (user == null) return;

    final hasMessage = state.messages.any((msg) => msg.id == newMessage.id);
    if (hasMessage) {
      _log.info('🔄 Message already exists, skipping: ${newMessage.id}');
      return;
    }

    final updatedMessages = [...state.messages, newMessage]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    emit(state.copyWith(messages: updatedMessages));

    final senderName =
        newMessage.sender.id == user.id ? user.name : newMessage.sender.name;
    _log.info('➕ New message from $senderName: ${newMessage.content}');
  }

  Future<void> loadMessages() async {
    if (_currentChatId == null) return;

    emit(state.copyWith(fetchMessagesStatus: FormzSubmissionStatus.inProgress));

    try {
      final result = await _messageRepository.getMessages(_currentChatId!);

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              fetchMessagesStatus: FormzSubmissionStatus.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (messages) {
          final sortedMessages = List<Message>.from(messages)
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          emit(
            state.copyWith(
              fetchMessagesStatus: FormzSubmissionStatus.success,
              messages: sortedMessages,
            ),
          );
          _log.info('📥 Loaded ${sortedMessages.length} messages');
        },
      );
    } catch (error) {
      emit(
        state.copyWith(
          fetchMessagesStatus: FormzSubmissionStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> sendMessage(String content) async {
    final user = _navCubit.state.user;
    if (user == null) return;

    if (_currentChatId == null || content.trim().isEmpty) return;

    emit(state.copyWith(sendMessageStatus: FormzSubmissionStatus.inProgress));

    try {
      final result = await _messageRepository.sendMessage(
        senderId: user.id,
        chatId: _currentChatId!,
        content: content.trim(),
        type: MessageType.text,
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              sendMessageStatus: FormzSubmissionStatus.failure,
              errorMessage: failure.message,
            ),
          );
          _log.severe('❌ Failed to send message: ${failure.message}');
        },
        (sentMessage) {
          emit(
            state.copyWith(
              sendMessageStatus: FormzSubmissionStatus.success,
            ),
          );
          _log.info(
            '✅ Message sent successfully, waiting for WebSocket: ${sentMessage.id}',
          );
        },
      );
    } catch (error) {
      emit(
        state.copyWith(
          sendMessageStatus: FormzSubmissionStatus.failure,
          errorMessage: error.toString(),
        ),
      );
      _log.severe('❌ Error sending message: $error');
    }
  }

  void resetSendMessageStatus() {
    emit(state.copyWith(sendMessageStatus: FormzSubmissionStatus.initial));
  }

  void clearError() {
    emit(state.copyWith());
  }

  @override
  Future<void> close() {
    // Leave chat and disconnect WebSocket when cubit is closed
    try {
      _messageRepository.leaveChat();
    } catch (e) {
      _log.severe('❌ Error leaving chat: $e');
    }
    return super.close();
  }
}
