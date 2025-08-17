import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

abstract class AppException extends Equatable implements Exception {
  const AppException([this.message = 'Something went wrong']);

  final String message;

  @override
  String toString() => message;

  @override
  List<Object> get props => [message];
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Request timeout']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Authentication required']);
}

class ForbiddenException extends AppException {
  const ForbiddenException([super.message = 'Access denied']);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found']);
}

class ValidationException extends AppException {
  const ValidationException([super.message = 'Invalid data provided']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Server error occurred']);
}

class UnknownException extends AppException {
  const UnknownException([super.message = 'Unknown error occurred']);
}

class ParseException extends AppException {
  const ParseException([super.message = 'Failed to parse response']);
}

class BadResponseException extends AppException {
  const BadResponseException([super.message = 'Bad response']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Cache operation failed']);
}

/// Factory class to create exceptions from Dio errors
class ExceptionFactory {
  static AppException fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const TimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        return _handleBadResponse(error);
      case DioExceptionType.cancel:
        return const UnknownException('Request cancelled');
      case DioExceptionType.badCertificate:
        return const ServerException('Invalid certificate');
      case DioExceptionType.unknown:
        return const UnknownException();
    }
  }

  static AppException _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;

    switch (statusCode) {
      case 400:
        return const ValidationException();
      case 401:
        return const UnauthorizedException();
      case 403:
        return const ForbiddenException();
      case 404:
        return const NotFoundException();
      case 500:
      case 502:
      case 503:
      case 504:
        return const ServerException();
      default:
        return const BadResponseException();
    }
  }
}
