import 'package:dartz/dartz.dart';
import 'package:logging/logging.dart';

import 'package:telegram_frontend/data/repositories/auth/auth_repository.dart';
import 'package:telegram_frontend/data/services/api/api_client.dart';
import 'package:telegram_frontend/data/services/api/auth_api_client.dart';
import 'package:telegram_frontend/data/services/api/model/login_request/login_request.dart';
import 'package:telegram_frontend/data/services/share_preference_service.dart';
import 'package:telegram_frontend/domain/error/exception.dart';
import 'package:telegram_frontend/domain/error/failure.dart';
import 'package:telegram_frontend/domain/models/user.dart';

class AuthRepositoryRemote extends AuthRepository {
  AuthRepositoryRemote({
    required ApiClient apiClient,
    required AuthApiClient authApiClient,
    required SharedPreferencesService sharedPreferencesService,
  })  : _apiClient = apiClient,
        _authApiClient = authApiClient,
        _sharedPreferencesService = sharedPreferencesService {
    // Initialize token from SharedPreferences and sync with ApiClient
    _initializeToken();
  }

  final AuthApiClient _authApiClient;
  final ApiClient _apiClient;
  final SharedPreferencesService _sharedPreferencesService;

  bool? _isAuthenticated;
  String? _authToken;
  User? _currentUser;
  final _log = Logger('AuthRepositoryRemote');

  Future<void> _initializeToken() async {
    await _fetch();
    // Sync token with ApiClient after fetching
    _apiClient.setAuthToken(_authToken);
  }

  Future<void> _fetch() async {
    try {
      final token = await _sharedPreferencesService.fetchToken();
      _authToken = token;
      _isAuthenticated = token != null;
      _currentUser = await _sharedPreferencesService.fetchUser();
    } catch (e) {
      _log.severe('Failed to fetch Token from SharedPreferences', e);
    }
  }

  @override
  Future<bool> get isAuthenticated async {
    if (_isAuthenticated != null) {
      return _isAuthenticated!;
    }
    await _fetch();
    return _isAuthenticated ?? false;
  }

  @override
  Future<Either<Failure, void>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _authApiClient.login(
        LoginRequest(email: email, password: password),
      );

      _log.info('User logged in');
      _isAuthenticated = true;
      _authToken = result.token;

      final user = result.user;

      _currentUser = User(
        id: user.id,
        name: user.name,
        email: user.email,
        profilePicture: user.profilePicture,
        isOnline: user.isOnline == 1,
        createdAt: DateTime.parse(user.createdAt),
      );

      // Sync token with ApiClient
      _apiClient.setAuthToken(result.token);

      // Save token to SharedPreferences
      await _sharedPreferencesService.saveToken(result.token);
      await _sharedPreferencesService.saveUser(_currentUser!);

      return const Right(null);
    } on AppException catch (e) {
      _log.severe('Error logging in: $e');
      return Left(FailureFactory.fromException(e));
    } catch (e) {
      _log.severe('Unexpected error logging in: $e');
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      _log.info('User logging out');

      await _sharedPreferencesService.clearUser();

      _currentUser = null;
      _authToken = null;
      _isAuthenticated = false;

      _apiClient.setAuthToken(null);

      _log.info('Logout successful');
      return const Right(null);
    } catch (e) {
      _log.severe('Unexpected error logging out: $e');
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    if (_currentUser != null) {
      return Right(_currentUser!);
    }

    final userResult = await _sharedPreferencesService.fetchUser();
    if (userResult == null) {
      return const Left(UnknownFailure());
    }
    _currentUser = userResult;
    return Right(userResult);
  }
}
