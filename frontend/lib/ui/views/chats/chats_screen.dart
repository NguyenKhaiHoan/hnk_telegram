import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:telegram_frontend/data/services/api/model/chat/chat_api_model.dart';
import 'package:telegram_frontend/gen/fonts.gen.dart';
import 'package:telegram_frontend/ui/core/themes/colors.dart';
import 'package:telegram_frontend/ui/views/chats/cubit/chats_cubit.dart';
import 'package:telegram_frontend/ui/views/chats/widgets/chat_item_widget.dart';
import 'package:telegram_frontend/ui/views/chats/widgets/short_stories_widget.dart';
import 'package:telegram_frontend/ui/views/chats/widgets/stories_widget.dart';
import 'package:telegram_frontend/utils/extentions/date_time_ext.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen>
    with TickerProviderStateMixin {
  late final ChatsCubit _chatCubit;
  late final TabController _tabController;
  final ValueNotifier<double> _progress = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _chatCubit = context.read<ChatsCubit>();
    _tabController = TabController(length: 4, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final chatType = _mapTabIndexToChatType(_tabController.index);
        if (chatType != null) {
          _chatCubit.markTabAsSeen(chatType);
        }
      }
    });
  }

  ChatType? _mapTabIndexToChatType(int index) {
    switch (index) {
      case 0:
        return null;
      case 1:
        return ChatType.group;
      case 2:
        return ChatType.channel;
      case 3:
        return ChatType.bot;
    }
    return null;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NotificationListener<ScrollNotification>(
        onNotification: (notif) {
          if (notif.metrics.axis == Axis.vertical) {
            final pixels = notif.metrics.pixels;
            const maxShrink = 60;
            _progress.value = (pixels / maxShrink).clamp(0.0, 1.0);
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: const Color(0xFFF7F7F7),
              expandedHeight: 50,
              toolbarHeight: 38,
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 12,
                ),
                expandedTitleScale: 20 / 18,
                title: Row(
                  children: [
                    const Text(
                      'Chats',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: FontFamily.roboto,
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ValueListenableBuilder(
                      valueListenable: _progress,
                      builder: (context, value, child) => Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: ShortStoriesWidget(
                          userId: _chatCubit.userId,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _StoriesHeaderDelegate(
                minExtent: 0,
                maxExtent: 98,
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarHeaderDelegate(
                child: BlocBuilder<ChatsCubit, ChatsState>(
                  builder: (context, state) {
                    return ColoredBox(
                      color: const Color(0xFFF7F7F7),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        tabAlignment: TabAlignment.start,
                        labelStyle: const TextStyle(
                          color: AppColors.telegramBlue,
                          fontSize: 14,
                          fontFamily: FontFamily.roboto,
                          fontWeight: FontWeight.w500,
                          height: 1.29,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          color: Color(0xFF828282),
                          fontSize: 14,
                          fontFamily: FontFamily.roboto,
                          fontWeight: FontWeight.w400,
                          height: 1.29,
                        ),
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        indicator: const UnderlineTabIndicator(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(3),
                            topRight: Radius.circular(3),
                          ),
                          borderSide: BorderSide(
                            width: 2.5,
                            color: AppColors.telegramBlue,
                          ),
                        ),
                        indicatorSize: TabBarIndicatorSize.label,
                        dividerHeight: 1,
                        dividerColor: const Color(0xFFEDEDED),
                        tabs: [
                          const Tab(
                            text: 'All',
                          ),
                          _TabWithBadge(
                            label: 'Groups',
                            badgeCount: state.unreadCounts[ChatType.group] ?? 0,
                            isNew: state.hasNewFor(ChatType.group),
                          ),
                          _TabWithBadge(
                            label: 'Channels',
                            badgeCount:
                                state.unreadCounts[ChatType.channel] ?? 0,
                            isNew: state.hasNewFor(ChatType.channel),
                          ),
                          _TabWithBadge(
                            label: 'Bots',
                            badgeCount: state.unreadCounts[ChatType.bot] ?? 0,
                            isNew: state.hasNewFor(ChatType.bot),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height:
                    MediaQuery.of(context).size.height - 200, // Fixed height
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildChatList(),
                    _buildChatList(chatType: ChatType.group),
                    _buildChatList(chatType: ChatType.channel),
                    _buildChatList(chatType: ChatType.bot),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList({ChatType? chatType}) {
    return BlocBuilder<ChatsCubit, ChatsState>(
      builder: (context, state) {
        if (state.fetchChatListStatus.isInProgress) {
          return const Center(child: CupertinoActivityIndicator());
        }

        if (state.fetchChatListStatus.isSuccess) {
          final chats = state.chats;

          final filteredChats = chatType == null
              ? chats
              : chats.where((chat) => chat.type == chatType).toList();

          if (filteredChats.isEmpty) {
            return const Center(
              child: Text('No chats found for this type'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: filteredChats.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final chat = filteredChats[index];
              return ChatItemWidget(
                chatId: chat.id,
                profilePicture: chat.profilePicture,
                name: chat.name,
                type: chat.type,
                unreadCount: chat.unreadCount,
                lastMessage: chat.lastMessage,
                lastMessageTime: chat.lastMessageTime.toChatFormat(),
                isMuted: chat.isMuted,
                isVerified: chat.isVerified,
              );
            },
            separatorBuilder: (context, index) => const SizedBox(
              height: 8,
            ),
          );
        }

        if (state.fetchChatListStatus.isFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.errorMessage}'),
                ElevatedButton(
                  onPressed: () => context.read<ChatsCubit>().loadChats(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}

class _TabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  _TabBarHeaderDelegate({required this.child});

  final Widget child;

  @override
  final double minExtent = 48;
  @override
  final double maxExtent = 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _TabBarHeaderDelegate oldDelegate) => true;
}

class _StoriesHeaderDelegate extends SliverPersistentHeaderDelegate {
  _StoriesHeaderDelegate({
    required this.minExtent,
    required this.maxExtent,
  });
  @override
  final double minExtent;
  @override
  final double maxExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final opacity = 1 - progress;

    return Opacity(
      opacity: opacity,
      child: Container(
        color: const Color(0xFFF7F7F7),
        alignment: Alignment.centerLeft,
        child: const SizedBox(
          height: 74,
          child: StoriesWidget(),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StoriesHeaderDelegate oldDelegate) => true;
}

class _TabWithBadge extends StatelessWidget {
  const _TabWithBadge({
    required this.label,
    required this.badgeCount,
    required this.isNew,
  });
  final String label;
  final int badgeCount;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    if (badgeCount == 0) {
      return Tab(text: label);
    }
    final Color badgeColor = isNew ? Colors.blue : Colors.grey;
    final isLargeBadge = badgeCount > 9;
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 4),
          Container(
            height: 18,
            width: isLargeBadge ? null : 18,
            padding: isLargeBadge
                ? const EdgeInsets.only(
                    left: 4,
                    right: 4,
                    top: 3,
                    bottom: 4,
                  )
                : null,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: isLargeBadge ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: isLargeBadge ? BorderRadius.circular(12) : null,
            ),
            alignment: Alignment.center,
            child: Text(
              badgeCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: FontFamily.roboto,
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
