import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import 'package:telegram_frontend/config/api_config.dart';
import 'package:telegram_frontend/domain/error/exception.dart';

class BaseDioClient {
  BaseDioClient({
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) : _dio = Dio() {
    _dio.options.baseUrl = baseUrl ?? ApiConfig.baseUrl;
    _dio.options.connectTimeout = connectTimeout ?? ApiConfig.connectTimeout;
    _dio.options.receiveTimeout = receiveTimeout ?? ApiConfig.receiveTimeout;
    _dio.options.sendTimeout = sendTimeout ?? ApiConfig.sendTimeout;

    _setupInterceptors();
  }

  final _log = Logger('BaseDioClient');
  final Dio _dio;
  String? _authToken;

  Dio get dio => _dio;

  void setAuthToken(String? token) {
    _authToken = token;
    _log.info('Auth token ${token != null ? 'set' : 'cleared'}');
  }

  void _setupInterceptors() {
    // Request Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }

          // Add content type
          options.headers['Content-Type'] = 'application/json';

          // Check network connectivity
          if (!await _checkNetworkConnectivity()) {
            _log.warning('No network connectivity detected');
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
                error: const NetworkException(),
              ),
            );
          }

          _log.info('🌐 ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _log.info(
            '✅ ${response.requestOptions.method} ${response.requestOptions.path} - ${response.statusCode}',
          );

          // Log response data for debugging
          if (response.data != null) {
            _log.fine('📡 Response data: ${response.data}');
          }

          handler.next(response);
        },
        onError: (error, handler) {
          _log.warning(
            '❌ ${error.requestOptions.method} ${error.requestOptions.path} - ${error.message}',
          );

          // Convert DioException to AppException using ExceptionFactory
          final appException = ExceptionFactory.fromDioError(error);

          // Reject with AppException
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              type: error.type,
              error: appException,
              response: error.response,
            ),
          );
        },
      ),
    );

    // Logging Interceptor (only in debug mode)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => _log.fine('📡 $object'),
      ),
    );
  }

  Future<bool> _checkNetworkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // Helper methods for common HTTP operations
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException {
      rethrow;
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException {
      rethrow;
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException {
      rethrow;
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException {
      rethrow;
    }
  }
}
