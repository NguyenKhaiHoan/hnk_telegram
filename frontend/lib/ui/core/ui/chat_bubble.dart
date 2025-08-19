import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:telegram_frontend/gen/fonts.gen.dart';
import 'package:telegram_frontend/ui/core/themes/colors.dart';

const double _kBubbleRadius = 10;
const double _kTailHeight = 10;
const double _kTailWidth = 6;

/// Demo chat using [ChatBubble]
///
/// ```dart
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: ChatScreen(),
//     );
//   }
// }

// class ChatScreen extends StatelessWidget {
//   const ChatScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final messages = <ChatMessage>[
//       ChatMessage(
//         text: 'Just ask - I will do everything for you.',
//         time: DateTime(2023, 1, 21, 10, 3),
//         isLeft: true,
//       ),
//       ChatMessage(
//         text: 'Well, yes, of course - you very rarely keep your promises.',
//         time: DateTime(2023, 1, 21, 0, 6),
//         isLeft: false,
//       ),
//       ChatMessage(
//         text: 'And you lie very often.',
//         time: DateTime(2023, 1, 21, 0, 7),
//         isLeft: false,
//       ),
//       ChatMessage(
//         text: "I don't know.",
//         time: DateTime(2023, 1, 21, 0, 8),
//         isLeft: false,
//       ),
//       ChatMessage(
//         text: 'Well, yes, of course - you very rarely keep your promises.',
//         time: DateTime(2023, 1, 21, 0, 20),
//         isLeft: false,
//       ),
//       ChatMessage(
//         text: 'And you lie very often.',
//         time: DateTime(2023, 1, 21, 0, 21),
//         isLeft: false,
//       ),
//       ChatMessage(
//         text: "I don't know.",
//         time: DateTime(2023, 1, 21, 0, 22),
//         isLeft: false,
//       ),
//       ChatMessage(
//         text: 'I always keep my promises',
//         time: DateTime(2023, 1, 21, 0, 34),
//         isLeft: true,
//       ),
//       ChatMessage(
//         text: 'Where is my flamethrower?',
//         time: DateTime(2023, 1, 21, 13, 50),
//         isLeft: false,
//       ),
//       ChatMessage(
//         text: 'Tomorrow, everything tomorrow...',
//         time: DateTime(2023, 1, 21, 6, 7),
//         isLeft: true,
//       ),
//       ChatMessage(
//         text: 'Okay',
//         time: DateTime(2023, 1, 21, 10, 24),
//         isLeft: false,
//       ),
//       // Tin nhắn sang ngày khác
//       ChatMessage(
//         text: 'Hello, new day!',
//         time: DateTime(2023, 1, 22, 9),
//         isLeft: true,
//       ),
//     ];

//     return Scaffold(
//       backgroundColor: Colors.black38,
//       appBar: AppBar(title: const Text('Telegram Style Chat')),
//       body: ListView.separated(
//         padding: const EdgeInsets.all(8),
//         itemCount: messages.length,
//         itemBuilder: (context, index) {
//           final msg = messages[index];

//           final showDateHeader =
//               index == 0 || !isSameDay(msg.time, messages[index - 1].time);

//           final isLastInGroup = index == messages.length - 1 ||
//               msg.isLeft != messages[index + 1].isLeft ||
//               !isSameDay(msg.time, messages[index + 1].time) ||
//               messages[index + 1].time.difference(msg.time).inMinutes > 5;

//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               if (showDateHeader)
//                 Center(
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(vertical: 8),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 7,
//                       vertical: 3,
//                     ),
//                     clipBehavior: Clip.antiAlias,
//                     decoration: ShapeDecoration(
//                       color: const Color(0x66728391),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(31.67),
//                       ),
//                     ),
//                     child: Text(
//                       DateFormat('d MMMM').format(msg.time),
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: Colors.black54,
//                       ),
//                     ),
//                   ),
//                 ),
//               Align(
//                 alignment:
//                     msg.isLeft ? Alignment.centerLeft : Alignment.centerRight,
//                 child: ChatBubble(
//                   message: msg.text,
//                   isLeft: msg.isLeft,
//                   time: msg.time,
//                   showTail: isLastInGroup,
//                 ),
//               ),
//             ],
//           );
//         },
//         separatorBuilder: (context, index) {
//           final current = messages[index];
//           final next = messages[index + 1];

//           final sameUser = current.isLeft == next.isLeft;
//           final sameDay = isSameDay(current.time, next.time);
//           final within5Min = next.time.difference(current.time).inMinutes <= 5;

//           final sameGroup = sameUser && sameDay && within5Min;

//           return SizedBox(height: sameGroup ? 2 : 6);
//         },
//       ),
//     );
//   }
// }

// class ChatMessage {
//   ChatMessage({required this.text, required this.time, required this.isLeft});
//   final String text;
//   final DateTime time;
//   final bool isLeft;
// }

/// ```
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    required this.message,
    required this.isLeft,
    required this.time,
    super.key,
    this.showTail = true,
    this.backgroundColor,
    this.textStyle,
  });

  final String message;
  final bool isLeft;
  final DateTime time;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final bool showTail;

  Color get _backgroundColor =>
      backgroundColor ??
      (isLeft ? AppColors.inBubbleMain : AppColors.outBubbleMain);

  TextStyle get _textStyle =>
      textStyle ??
      const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontFamily: FontFamily.roboto,
        fontWeight: FontWeight.w400,
        height: 1.19,
      );

  TextStyle get _timeStyle => TextStyle(
        color: isLeft ? AppColors.inBubbleService : AppColors.outBubbleService,
        fontSize: 12,
        fontFamily: FontFamily.roboto,
        fontWeight: FontWeight.w400,
        height: 1.17,
      );

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BubbleTailPainter(
        color: _backgroundColor,
        isLeft: isLeft,
        showTail: showTail,
      ),
      child: Container(
        padding: isLeft
            ? const EdgeInsets.fromLTRB(8 + _kTailWidth, 5, 8, 0)
            : const EdgeInsets.fromLTRB(8, 5, 8 + _kTailWidth, 0),
        constraints: const BoxConstraints(maxWidth: 260),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: _textStyle),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                DateFormat('HH:mm a').format(time),
                style: _timeStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BubbleTailPainter extends CustomPainter {
  BubbleTailPainter({
    required this.color,
    required this.isLeft,
    this.showTail = true,
  });
  final Color color;
  final bool isLeft;
  final bool showTail;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    if (isLeft) {
      path.moveTo(_kTailWidth, size.height - _kTailHeight);

      if (showTail) {
        // Tail bottom-left
        path
          ..cubicTo(
            5.2,
            size.height - 6,
            3.3,
            size.height - 3,
            0.7,
            size.height - 1.4,
          )
          ..arcTo(
            Rect.fromCircle(
              center: Offset(0.7, size.height - 0.7),
              radius: 0.7,
            ),
            -pi / 2,
            -pi,
            false,
          );
      } else {
        // Bottom-left corner
        path
          ..lineTo(_kTailWidth, size.height - _kBubbleRadius)
          ..arcTo(
            Rect.fromCircle(
              center: Offset(
                _kTailWidth + _kBubbleRadius,
                size.height - _kBubbleRadius,
              ),
              radius: _kBubbleRadius,
            ),
            pi,
            -pi / 2,
            false,
          );
      }

      // Bottom-right
      path
        ..lineTo(size.width - _kBubbleRadius, size.height)
        ..arcTo(
          Rect.fromCircle(
            center: Offset(
              size.width - _kBubbleRadius,
              size.height - _kBubbleRadius,
            ),
            radius: _kBubbleRadius,
          ),
          pi / 2,
          -pi / 2,
          false,
        )

        // Top-right
        ..lineTo(size.width, _kBubbleRadius)
        ..arcTo(
          Rect.fromCircle(
            center: Offset(size.width - _kBubbleRadius, _kBubbleRadius),
            radius: _kBubbleRadius,
          ),
          0,
          -pi / 2,
          false,
        )

        // Top-left
        ..lineTo(_kTailWidth + _kBubbleRadius, 0)
        ..arcTo(
          Rect.fromCircle(
            center: const Offset(_kTailWidth + _kBubbleRadius, _kBubbleRadius),
            radius: _kBubbleRadius,
          ),
          -pi / 2,
          -pi / 2,
          false,
        )
        ..lineTo(_kTailWidth, size.height - _kTailHeight);
    } else {
      path.moveTo(size.width - _kTailWidth, size.height - _kTailHeight);

      if (showTail) {
        // Tail bottom-right
        path
          ..cubicTo(
            size.width - 5.2,
            size.height - 6,
            size.width - 3.3,
            size.height - 3,
            size.width - 0.7,
            size.height - 1.4,
          )
          ..arcTo(
            Rect.fromCircle(
              center: Offset(size.width - 0.7, size.height - 0.7),
              radius: 0.7,
            ),
            -pi / 2,
            pi,
            false,
          );
      } else {
        // Bottom-right corner
        path
          ..lineTo(size.width - _kTailWidth, size.height - _kBubbleRadius)
          ..arcTo(
            Rect.fromCircle(
              center: Offset(
                size.width - _kTailWidth - _kBubbleRadius,
                size.height - _kBubbleRadius,
              ),
              radius: _kBubbleRadius,
            ),
            0,
            pi / 2,
            false,
          );
      }

      // Bottom-left
      path
        ..lineTo(_kBubbleRadius, size.height)
        ..arcTo(
          Rect.fromCircle(
            center: Offset(_kBubbleRadius, size.height - _kBubbleRadius),
            radius: _kBubbleRadius,
          ),
          pi / 2,
          pi / 2,
          false,
        )

        // Top-left
        ..lineTo(0, _kBubbleRadius)
        ..arcTo(
          Rect.fromCircle(
            center: const Offset(_kBubbleRadius, _kBubbleRadius),
            radius: _kBubbleRadius,
          ),
          pi,
          pi / 2,
          false,
        )

        // Top-right
        ..lineTo(size.width - _kTailWidth - _kBubbleRadius, 0)
        ..arcTo(
          Rect.fromCircle(
            center: Offset(
              size.width - _kTailWidth - _kBubbleRadius,
              _kBubbleRadius,
            ),
            radius: _kBubbleRadius,
          ),
          -pi / 2,
          pi / 2,
          false,
        )
        ..lineTo(size.width - _kTailWidth, size.height - _kTailHeight);
    }

    path.close();

    final paintFill = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    canvas.drawPath(path, paintFill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
