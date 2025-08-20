import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:intl/intl.dart';

import 'package:telegram_frontend/domain/models/message.dart';
import 'package:telegram_frontend/ui/core/ui/chat_bubble.dart';
import 'package:telegram_frontend/ui/views/groups/cubit/groups_cubit.dart';
import 'package:telegram_frontend/ui/views/nav/nav.dart';

enum GroupType {
  withoutTopics,
  withTopics,
}

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({
    required this.chatId,
    required this.chatName,
    super.key,
  });

  final String chatId;
  final String chatName;
  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x9B7CA7DA), Color(0xC17FEBA4)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.chatName),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<GroupsCubit, GroupsState>(
                builder: (context, state) {
                  if (state.fetchMessagesStatus.isInProgress) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state.fetchMessagesStatus.isFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Failed to load messages',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () =>
                                context.read<GroupsCubit>().loadMessages(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state.messages.isEmpty) {
                    return const Center(
                      child: Text(
                        'No messages yet',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return ListView.separated(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final isLastInGroup = index == 0 ||
                          _shouldShowTail(message, state.messages, index);

                      final showDateHeader =
                          index == state.messages.length - 1 ||
                              !_isSameDay(
                                message.timestamp,
                                state.messages[index + 1].timestamp,
                              );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showDateHeader)
                            Center(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: const Color(0x66728391),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(31.67),
                                  ),
                                ),
                                child: Text(
                                  DateFormat('d MMMM')
                                      .format(message.timestamp),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          Align(
                            alignment: _isFromCurrentUser(message)
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: ChatBubble(
                              message: message.content,
                              isLeft: !_isFromCurrentUser(message),
                              time: message.timestamp,
                              showTail: isLastInGroup,
                            ),
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (context, index) {
                      final current = state.messages[index];
                      final next = state.messages[index + 1];

                      final sameUser = _isFromCurrentUser(current) ==
                          _isFromCurrentUser(next);
                      final sameDay =
                          _isSameDay(current.timestamp, next.timestamp);
                      final within5Min = next.timestamp
                              .difference(current.timestamp)
                              .inMinutes <=
                          5;

                      final sameGroup = sameUser && sameDay && within5Min;

                      return SizedBox(height: sameGroup ? 2 : 6);
                    },
                  );
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  context.read<GroupsCubit>().sendMessage(text);
                  _messageController.clear();
                  _scrollToBottom();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              if (_messageController.text.trim().isNotEmpty) {
                context
                    .read<GroupsCubit>()
                    .sendMessage(_messageController.text);
                _messageController.clear();
                _scrollToBottom();
              }
            },
            icon: const Icon(Icons.send),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  bool _isFromCurrentUser(Message message) {
    final user = context.read<NavCubit>().state.user;
    if (user == null) return false;
    return message.sender.id == user.id;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _shouldShowTail(
    Message currentMessage,
    List<Message> messages,
    int index,
  ) {
    if (index == messages.length - 1) return true;

    final nextMessage = messages[index + 1];
    final sameUser =
        _isFromCurrentUser(currentMessage) == _isFromCurrentUser(nextMessage);
    final sameDay = _isSameDay(currentMessage.timestamp, nextMessage.timestamp);
    final within5Min =
        nextMessage.timestamp.difference(currentMessage.timestamp).inMinutes <=
            5;

    return !sameUser || !sameDay || !within5Min;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
