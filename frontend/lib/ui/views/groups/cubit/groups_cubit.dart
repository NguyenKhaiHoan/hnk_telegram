import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:logging/logging.dart';

import 'package:telegram_frontend/data/repositories/message/message_repository.dart';
import 'package:telegram_frontend/domain/models/message.dart';
import 'package:telegram_frontend/ui/core/cubit/base_cubit.dart';
import 'package:telegram_frontend/ui/views/nav/cubit/nav_cubit.dart';
import 'package:telegram_frontend/utils/constant.dart';

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
      final result = await _messageRepository.getPaginated(
        _currentChatId,
        limit: defaultLimit,
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              fetchMessagesStatus: FormzSubmissionStatus.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (paginatedResponse) {
          final sortedMessages = List<Message>.from(paginatedResponse.items)
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          final oldestTimestamp =
              sortedMessages.isNotEmpty ? sortedMessages.last.timestamp : null;

          emit(
            state.copyWith(
              fetchMessagesStatus: FormzSubmissionStatus.success,
              messages: sortedMessages,
              oldestMessageTimestamp: oldestTimestamp,
              hasMoreMessages: paginatedResponse.hasMore,
            ),
          );
          _log.info(
            '📥 Loaded ${sortedMessages.length}/${paginatedResponse.total} messages',
          );
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

  Future<void> loadMoreMessages() async {
    if (_currentChatId == null ||
        !state.hasMoreMessages ||
        state.isLoadingMore ||
        state.oldestMessageTimestamp == null) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));

    try {
      final result = await _messageRepository.getPaginated(
        _currentChatId,
        limit: defaultLimit,
        offset: state.messages.length,
      );

      result.fold(
        (failure) {
          emit(state.copyWith(isLoadingMore: false));
          _log.severe('❌ Failed to load more messages: ${failure.message}');
        },
        (paginatedResponse) {
          if (!paginatedResponse.hasMore) {
            emit(
              state.copyWith(
                isLoadingMore: false,
                hasMoreMessages: false,
              ),
            );
            _log.info('📥 No more messages to load');
            return;
          }

          final newMessages = paginatedResponse.items;

          final allMessages = [...state.messages, ...newMessages];
          final sortedMessages = allMessages
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          final oldestTimestamp =
              sortedMessages.isNotEmpty ? sortedMessages.last.timestamp : null;

          emit(
            state.copyWith(
              messages: sortedMessages,
              isLoadingMore: false,
              oldestMessageTimestamp: oldestTimestamp,
              hasMoreMessages: paginatedResponse.hasMore,
            ),
          );

          _log.info(
            '📥 Loaded ${paginatedResponse.items.length} more messages (${sortedMessages.length}/${paginatedResponse.total} total)',
          );
        },
      );
    } catch (error) {
      emit(state.copyWith(isLoadingMore: false));
      _log.severe('❌ Error loading more messages: $error');
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
