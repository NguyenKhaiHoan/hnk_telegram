import 'package:intl/intl.dart';

extension ChatDateTimeExtension on DateTime {
  String toChatFormat() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(year, month, day);
    final difference = today.difference(messageDay).inDays;

    if (difference == 0) {
      return DateFormat('HH:mm').format(this);
    }

    if (difference < 7 && today.weekday > weekday) {
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[weekday - 1];
    }

    if (now.year == year) {
      return '$day/$month';
    }

    return '$day/$month/${year % 100}';
  }
}
