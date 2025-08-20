import 'package:dartz/dartz.dart';

import 'package:telegram_frontend/data/repositories/chat/chat_repository.dart';
import 'package:telegram_frontend/domain/error/failure.dart';
import 'package:telegram_frontend/domain/models/chat.dart';
import 'package:telegram_frontend/domain/models/paginated_response.dart';

class ChatRepositoryLocal extends ChatRepository {
  @override
  Future<Either<Failure, PaginatedResponse<Chat>>> getPaginated(
    dynamic params, {
    int? limit,
    int? offset,
  }) async {
    throw UnimplementedError();
  }
}
