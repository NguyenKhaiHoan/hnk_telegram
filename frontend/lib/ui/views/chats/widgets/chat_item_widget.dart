import 'package:flutter/material.dart';

import 'package:telegram_frontend/data/services/api/model/chat/chat_api_model.dart';
import 'package:telegram_frontend/gen/assets.gen.dart';
import 'package:telegram_frontend/gen/fonts.gen.dart';
import 'package:telegram_frontend/routing/routes.dart';
import 'package:telegram_frontend/ui/core/themes/colors.dart';
import 'package:telegram_frontend/ui/core/ui/circle_network_avartar.dart';

class ChatItemWidget extends StatelessWidget {
  const ChatItemWidget({
    required this.chatId,
    required this.profilePicture,
    required this.name,
    required this.type,
    required this.unreadCount,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.isMuted,
    required this.isVerified,
    super.key,
  });

  final String chatId;
  final String name;
  final String profilePicture;
  final ChatType type;
  final int unreadCount;
  final String lastMessage;
  final String lastMessageTime;
  final bool isMuted;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final isLargeUnreadCount = unreadCount > 9;

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.chat,
          arguments: {
            'chatId': chatId,
            'chatName': name,
            'profilePicture': profilePicture,
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleNetworkAvartar(
              imageUrl: profilePicture,
              width: 54,
              height: 54,
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Container(
                height: 66,
                padding: const EdgeInsets.only(
                  left: 4,
                  top: 4,
                  bottom: 4,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFD9D9D9),
                      width: 0.35,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNameRow(),
                    const SizedBox(height: 4),
                    _buildLastMessageRow(isLargeUnreadCount),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF222222),
                    fontSize: 16,
                    fontFamily: FontFamily.roboto,
                    fontWeight: FontWeight.w500,
                    height: 1.19,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isVerified) ...[
                const SizedBox(width: 4),
                Assets.icons.icVerified.svg(height: 18, width: 18),
              ],
              if (isMuted) ...[
                const SizedBox(width: 4),
                Assets.icons.icMute.svg(height: 16, width: 16),
              ],
            ],
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Text(
          lastMessageTime,
          style: const TextStyle(
            color: Color(0xFF95999A),
            fontSize: 13,
            fontFamily: FontFamily.roboto,
            fontWeight: FontWeight.w400,
            height: 1.15,
          ),
        ),
      ],
    );
  }

  Widget _buildLastMessageRow(bool isLargeUnreadCount) {
    return Row(
      children: [
        Expanded(
          child: Text(
            lastMessage,
            style: const TextStyle(
              color: Color(0xFF8D8E90),
              fontSize: 15,
              fontFamily: FontFamily.roboto,
              fontWeight: FontWeight.w400,
              height: 1.20,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (unreadCount > 0) ...[
          const SizedBox(width: 6),
          _buildUnreadBadge(isLargeUnreadCount),
        ],
      ],
    );
  }

  Widget _buildUnreadBadge(bool isLargeUnreadCount) {
    return Container(
      height: 24,
      width: isLargeUnreadCount ? null : 24,
      padding: isLargeUnreadCount
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
          : null,
      decoration: BoxDecoration(
        color: isMuted ? const Color(0xFFB7B6BB) : AppColors.telegramBlue,
        shape: isLargeUnreadCount ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: isLargeUnreadCount ? BorderRadius.circular(12) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        unreadCount.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13.37,
          fontFamily: FontFamily.roboto,
          fontWeight: FontWeight.w500,
          height: 1,
        ),
      ),
    );
  }
}
