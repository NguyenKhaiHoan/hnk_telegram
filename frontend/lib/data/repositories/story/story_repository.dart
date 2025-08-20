import 'package:dartz/dartz.dart';

import 'package:telegram_frontend/data/repositories/base_repository.dart';
import 'package:telegram_frontend/domain/error/failure.dart';
import 'package:telegram_frontend/domain/models/paginated_response.dart';
import 'package:telegram_frontend/domain/models/story.dart';

abstract class StoryRepository extends BaseRepository<Story> {
  @override
  Future<Either<Failure, PaginatedResponse<Story>>> getPaginated(
    dynamic params, {
    int? limit,
    int? offset,
  });
}
