import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../config/assets.dart';

class UserApi {
  Router get router {
    final router = Router()
      ..get('/', (Request request) async {
        try {
          final usersWithoutPassword = Assets.users
              .map(
                (user) => {
                  'id': user.id,
                  'name': user.name,
                  'email': user.email,
                  'isOnline': user.isOnline,
                  'createdAt': user.createdAt.toIso8601String(),
                },
              )
              .toList();

          return Response.ok(
            json.encode(usersWithoutPassword),
            headers: {'Content-Type': 'application/json'},
          );
        } catch (e) {
          return Response.internalServerError(
            body: json.encode({'error': 'Failed to fetch users'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
      })
      ..get('/<id>', (Request request, String id) async {
        try {
          final user = Assets.users.firstWhere(
            (user) => user.id == id,
            orElse: () => throw Exception('User not found'),
          );

          final userWithoutPassword = {
            'id': user.id,
            'name': user.name,
            'email': user.email,
            'isOnline': user.isOnline,
            'createdAt': user.createdAt.toIso8601String(),
          };

          return Response.ok(
            json.encode(userWithoutPassword),
            headers: {'Content-Type': 'application/json'},
          );
        } catch (e) {
          return Response.notFound(
            json.encode({'error': 'User not found'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
      })
      ..put('/<id>/online', (Request request, String id) async {
        try {
          final userIndex = Assets.users.indexWhere((user) => user.id == id);
          if (userIndex == -1) {
            return Response.notFound(
              json.encode({'error': 'User not found'}),
              headers: {'Content-Type': 'application/json'},
            );
          }

          return Response.ok(
            json.encode({'message': 'User online status updated'}),
            headers: {'Content-Type': 'application/json'},
          );
        } catch (e) {
          return Response.internalServerError(
            body: json.encode({'error': 'Failed to update user status'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
      });

    return router;
  }
}
