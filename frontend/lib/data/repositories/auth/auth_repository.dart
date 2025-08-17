import 'package:dartz/dartz.dart';

import 'package:telegram_frontend/domain/error/failure.dart';
import 'package:telegram_frontend/domain/models/user.dart';

abstract class AuthRepository {
  Future<bool> get isAuthenticated;

  Future<Either<Failure, void>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User>> getCurrentUser();
}
