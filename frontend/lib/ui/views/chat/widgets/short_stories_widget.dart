import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:telegram_frontend/domain/models/story.dart';
import 'package:telegram_frontend/ui/core/themes/colors.dart';
import 'package:telegram_frontend/ui/core/ui/circle_network_avartar.dart';
import 'package:telegram_frontend/ui/views/chat/cubit/chats_cubit.dart';

const _kOverlapStories = 20.0;

class ShortStoriesWidget extends StatelessWidget {
  const ShortStoriesWidget({
    super.key,
    this.userId,
  });

  final String? userId;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ChatsCubit, ChatsState, List<Story>>(
      selector: (state) => state.stories,
      builder: (context, stories) {
        final otherStories = stories
            .where(
              (story) => story.userId != userId,
            )
            .toList();
        final storyCount = otherStories.length.clamp(0, 3);

        if (storyCount > 0) {
          final color = List<Color>.generate(
            storyCount,
            (index) => stories[index].isSeen
                ? const Color(0xFFE8E8E8)
                : AppColors.telegramBlue,
          );

          return SizedBox(
            width: 70,
            height: 28,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                CustomPaint(
                  size: const Size(70, 28),
                  painter: CircleChainPainter(
                    count: storyCount,
                    circleColors: color,
                  ),
                ),
                Stack(
                  children: List.generate(storyCount, (index) {
                    final reversedIndex = storyCount - 1 - index;
                    final story = otherStories[reversedIndex];

                    return Positioned(
                      left: reversedIndex * _kOverlapStories,
                      child: _StoryAvatar(
                        imageUrl: story.userProfilePicture,
                        borderColor: Colors.transparent,
                      ),
                    );
                  }),
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
      width: 28,
      height: 28,
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: CircleNetworkAvartar(imageUrl: imageUrl),
    );
  }
}

class CircleChainPainter extends CustomPainter {
  CircleChainPainter({
    required this.count,
    required this.circleColors,
    this.overlap = _kOverlapStories,
    super.repaint,
  }) : assert(
          circleColors.length == count,
          'circleColors.length (${circleColors.length}) must equal count ($count)',
        );

  final int count;
  final List<Color> circleColors;
  final double overlap;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.height / 2;

    for (var i = 0; i < count; i++) {
      final paint = Paint()
        ..color = circleColors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      final dx = i * overlap + radius;
      final dy = radius;

      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CircleChainPainter oldDelegate) {
    return oldDelegate.count != count ||
        oldDelegate.circleColors != circleColors ||
        oldDelegate.overlap != overlap;
  }
}
