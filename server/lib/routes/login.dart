import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../config/assets.dart';
import '../model/login_request/login_request.dart';
import '../model/login_response/login_response.dart';

class LoginApi {
  Router get router {
    final router =
        Router()..post('/', (Request request) async {
          try {
            final body = await request.readAsString();
            final loginRequest = LoginRequest.fromJson(
              json.decode(body) as Map<String, Object?>,
            );

            final user = Assets.users.firstWhere(
              (user) =>
                  user.email == loginRequest.email &&
                  user.password == loginRequest.password,
              orElse: () => throw Exception('User not found'),
            );

            final userData = UserData(
              id: user.id,
              name: user.name,
              email: user.email,
              createdAt: user.createdAt,
              profilePicture: user.profilePicture,
              isOnline: user.isOnline,
            );

            return Response.ok(
              json.encode(
                LoginResponse(token: 'token_${user.id}', user: userData),
              ),
              headers: {'Content-Type': 'application/json'},
            );
          } catch (e) {
            return Response.unauthorized(
              json.encode({'error': 'Invalid credentials: $e'}),
              headers: {'Content-Type': 'application/json'},
            );
          }
        });

    return router;
  }
}
