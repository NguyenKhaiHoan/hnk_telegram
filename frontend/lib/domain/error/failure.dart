import 'package:equatable/equatable.dart';

import 'package:telegram_frontend/domain/error/exception.dart';

abstract class Failure extends Equatable {
  const Failure([this.message = 'Something went wrong']);

  final String message;

  @override
  String toString() => message;

  @override
  List<Object> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timeout']);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure([super.message = 'Authentication failed']);
}

class AuthorizationFailure extends Failure {
  const AuthorizationFailure([super.message = 'Access denied']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Invalid data provided']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache operation failed']);
}

class ParseFailure extends Failure {
  const ParseFailure([super.message = 'Failed to parse response']);
}

class BadResponseFailure extends Failure {
  const BadResponseFailure([super.message = 'Bad response']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unknown error occurred']);
}

/// Factory class to create failures from exceptions
class FailureFactory {
  static Failure fromException(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkException:
        return NetworkFailure(exception.message);
      case TimeoutException:
        return TimeoutFailure(exception.message);
      case UnauthorizedException:
        return AuthenticationFailure(exception.message);
      case ForbiddenException:
        return AuthorizationFailure(exception.message);
      case NotFoundException:
        return NotFoundFailure(exception.message);
      case ValidationException:
        return ValidationFailure(exception.message);
      case ServerException:
        return ServerFailure(exception.message);
      case CacheException:
        return CacheFailure(exception.message);
      case ParseException:
        return ParseFailure(exception.message);
      case BadResponseException:
        return BadResponseFailure(exception.message);
      case UnknownException:
      default:
        return UnknownFailure(exception.message);
    }
  }

  static Failure fromDioError(dynamic error) {
    if (error is AppException) {
      return fromException(error);
    }

    return UnknownFailure(error.toString());
  }
}
