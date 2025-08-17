import 'package:dartz/dartz.dart';

import 'package:telegram_frontend/domain/error/failure.dart';
import 'package:telegram_frontend/domain/models/chat.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<Chat>>> getChats();

  Future<Either<Failure, Chat>> getChat(String chatId);
}
