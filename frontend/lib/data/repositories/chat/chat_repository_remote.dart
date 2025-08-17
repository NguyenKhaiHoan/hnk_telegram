import 'package:dartz/dartz.dart';
import 'package:logging/logging.dart';

import 'package:telegram_frontend/data/repositories/chat/chat_repository.dart';
import 'package:telegram_frontend/data/services/api/api_client.dart';
import 'package:telegram_frontend/data/translators/chat_translator.dart';
import 'package:telegram_frontend/domain/error/exception.dart';
import 'package:telegram_frontend/domain/error/failure.dart';
import 'package:telegram_frontend/domain/models/chat.dart';

class ChatRepositoryRemote implements ChatRepository {
  ChatRepositoryRemote({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;
  final _log = Logger('ChatRepositoryRemote');

  @override
  Future<Either<Failure, List<Chat>>> getChats() async {
    try {
      _log.info('Fetching chats...');
      final chatApiModels = await _apiClient.getChats();
      final chats = chatApiModels
          .map((apiModel) => ChatTranslator().toDomain(apiModel))
          .toList();

      _log.info('Successfully fetched ${chats.length} chats');
      return Right(chats);
    } on AppException catch (e) {
      _log.severe('AppException in getChats: $e');
      return Left(FailureFactory.fromException(e));
    } catch (e) {
      _log.severe('Unexpected error in getChats: $e');
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Chat>> getChat(String chatId) async {
    try {
      final chatApiModel = await _apiClient.getChat(chatId);
      final chat = ChatTranslator().toDomain(chatApiModel);
      return Right(chat);
    } on AppException catch (e) {
      _log.severe('AppException in getChat: $e');
      return Left(FailureFactory.fromException(e));
    } catch (e) {
      _log.severe('Unexpected error in getChat: $e');
      return const Left(UnknownFailure());
    }
  }
}
