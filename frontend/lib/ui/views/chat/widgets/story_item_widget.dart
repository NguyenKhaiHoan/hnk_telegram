import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:telegram_frontend/gen/fonts.gen.dart';
import 'package:telegram_frontend/ui/core/themes/colors.dart';
import 'package:telegram_frontend/ui/core/ui/circle_network_avartar.dart';

class StoryItemWidget extends StatelessWidget {
  const StoryItemWidget({
    required this.userProfilePicture,
    required this.userName,
    required this.isActive,
    required this.isSeen,
    required this.isCurrentUserStory,
    this.onTap,
    super.key,
  });

  final String userProfilePicture;
  final String userName;
  final bool isActive;
  final bool isSeen;
  final bool isCurrentUserStory;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final showCreateStory = isCurrentUserStory && !isActive;

    return SizedBox(
      width: 54,
      height: 74,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: onTap,
            child: Stack(
              children: [
                _StoryAvatar(
                  imageUrl: userProfilePicture,
                  borderColor: showCreateStory
                      ? const Color(0xFFE8E8E8)
                      : (isSeen
                          ? const Color(0xFFE8E8E8)
                          : AppColors.telegramBlue),
                ),
                if (showCreateStory)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 19,
                      width: 19,
                      padding: const EdgeInsets.all(1.5),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.telegramBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.add,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            isCurrentUserStory ? 'My story' : userName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF828282),
              fontSize: 10,
              fontFamily: FontFamily.roboto,
              fontWeight: FontWeight.w400,
              height: 1.60,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StoryAvatar extends StatelessWidget {
  const _StoryAvatar({
    required this.imageUrl,
    required this.borderColor,
  });

  final String imageUrl;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor),
      ),
      child: CircleNetworkAvartar(imageUrl: imageUrl),
    );
  }
}
