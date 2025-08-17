import 'package:dio/dio.dart';
import 'package:telegram_frontend/data/services/api/base_dio_client.dart';
import 'package:telegram_frontend/data/services/api/model/login_request/login_request.dart';
import 'package:telegram_frontend/data/services/api/model/login_response/login_response.dart';
import 'package:telegram_frontend/domain/error/exception.dart';

class AuthApiClient extends BaseDioClient {
  AuthApiClient({
    super.baseUrl,
  });

  Future<LoginResponse> login(LoginRequest loginRequest) async {
    try {
      final response = await post<dynamic>(
        '/login',
        data: loginRequest.toJson(),
      );
      return LoginResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ExceptionFactory.fromDioError(e);
    }
  }
}
