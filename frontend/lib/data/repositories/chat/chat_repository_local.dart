import 'package:dartz/dartz.dart';

import 'package:telegram_frontend/data/repositories/chat/chat_repository.dart';
import 'package:telegram_frontend/domain/error/failure.dart';
import 'package:telegram_frontend/domain/models/chat.dart';

class ChatRepositoryLocal implements ChatRepository {
  @override
  Future<Either<Failure, List<Chat>>> getChats() async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Chat>> getChat(String chatId) async {
    throw UnimplementedError();
  }
}
