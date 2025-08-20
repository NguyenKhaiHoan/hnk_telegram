import 'package:dartz/dartz.dart';

import 'package:telegram_frontend/domain/error/failure.dart';
import 'package:telegram_frontend/domain/models/paginated_response.dart';

/// Base repository interface for paginated data
abstract class BaseRepository<T> {
  /// Get paginated items
  Future<Either<Failure, PaginatedResponse<T>>> getPaginated(
    dynamic params, {
    int? limit,
    int? offset,
  });
}
