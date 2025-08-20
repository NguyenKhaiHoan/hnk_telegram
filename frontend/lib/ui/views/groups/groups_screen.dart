import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:intl/intl.dart';

import 'package:telegram_frontend/domain/models/message.dart';
import 'package:telegram_frontend/gen/assets.gen.dart';
import 'package:telegram_frontend/gen/fonts.gen.dart';
import 'package:telegram_frontend/ui/core/themes/colors.dart';
import 'package:telegram_frontend/ui/core/ui/chat_bubble.dart';
import 'package:telegram_frontend/ui/core/ui/circle_network_avartar.dart';
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
    required this.profilePicture,
    super.key,
  });

  final String chatId;
  final String chatName;
  final String profilePicture;
  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final GroupsCubit _groupsCubit;

  @override
  void initState() {
    super.initState();
    _groupsCubit = context.read<GroupsCubit>();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent + 100) {
        if (_groupsCubit.state.hasMoreMessages &&
            !_groupsCubit.state.isLoadingMore) {
          _groupsCubit.loadMoreMessages();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF7CA8DB).withValues(alpha: 0.61),
            const Color(0xFF80ECA5).withValues(alpha: 0.76),
          ],
        ),
        image: DecorationImage(
          image: Assets.images.imgChatBackground.provider(),
          fit: BoxFit.cover,
          colorFilter: const ColorFilter.mode(
            Colors.transparent,
            BlendMode.color,
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: Container(
            margin: const EdgeInsets.only(left: 8),
            alignment: Alignment.centerLeft,
            child: IconButton(
              padding: const EdgeInsets.all(8),
              onPressed: () => Navigator.pop(context),
              icon: Assets.icons.icBack.svg(
                width: 24,
                height: 24,
              ),
            ),
          ),
          titleSpacing: 12,
          centerTitle: true,
          title: Row(
            spacing: 16,
            children: [
              CircleNetworkAvartar(
                imageUrl: widget.profilePicture,
                width: 48,
                height: 48,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 6,
                  children: [
                    Text(
                      widget.chatName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: FontFamily.roboto,
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),
                    const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '55 Members, ',
                            style: TextStyle(
                              color: Color(0xFF828282),
                              fontSize: 14,
                              fontFamily: FontFamily.roboto,
                              fontWeight: FontWeight.w400,
                              height: 1.29,
                            ),
                          ),
                          TextSpan(
                            text: '12 online',
                            style: TextStyle(
                              color: AppColors.telegramBlue,
                              fontSize: 14,
                              fontFamily: FontFamily.roboto,
                              fontWeight: FontWeight.w400,
                              height: 1.29,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              padding: const EdgeInsets.all(8),
              onPressed: () {},
              icon: Assets.icons.icDot.svg(
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(width: 17),
          ],
          backgroundColor: const Color(0xFFFAFAFA),
          scrolledUnderElevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<GroupsCubit, GroupsState>(
                builder: (context, state) {
                  if (state.fetchMessagesStatus.isInProgress) {
                    return const Center(
                      child: CupertinoActivityIndicator(),
                    );
                  }

                  if (state.fetchMessagesStatus.isFailure) {
                    return const SizedBox.shrink();
                  }

                  if (state.messages.isEmpty) {
                    return const Center(
                      child: Text(
                        'No messages yet',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      if (state.isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.all(8),
                          child: Center(
                            child: CupertinoActivityIndicator(),
                          ),
                        ),
                      Expanded(
                        child: ListView.separated(
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
                                          borderRadius:
                                              BorderRadius.circular(31.67),
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
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            _buildMessagePanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagePanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 10, 13, 13),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Assets.icons.icEmoji.svg(
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: FontFamily.roboto,
                  fontWeight: FontWeight.w400,
                  height: 1.19,
                ),
                cursorHeight: 23,
                cursorColor: const Color(0xFF55A1DB),
                decoration: const InputDecoration(
                  hintText: 'Message...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 2),
                  hintStyle: TextStyle(
                    color: Color(0xFFA3ACB3),
                    fontSize: 16,
                    fontFamily: FontFamily.roboto,
                    fontWeight: FontWeight.w400,
                    height: 1.19,
                  ),
                ),
                onSubmitted: (text) {
                  if (text.trim().isNotEmpty) {
                    _groupsCubit.sendMessage(text);
                    _messageController.clear();
                    _scrollToBottom();
                  }
                },
              ),
            ),
            const SizedBox(width: 18),
            Assets.icons.icAttach.svg(
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 18),
            Assets.icons.icVoice.svg(
              width: 24,
              height: 24,
            ),
          ],
        ),
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
