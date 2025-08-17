import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:telegram_server/config/constants.dart';
import 'package:telegram_server/model/login_request/login_request.dart';
import 'package:telegram_server/model/login_response/login_response.dart';
import 'package:telegram_server/model/user/user.dart';
import 'package:test/test.dart';

void main() {
  const port = '8080';
  const host = 'http://127.0.0.1:$port';
  late Process p;

  final headers = {'Authorization': 'Bearer ${Constants.token}'};

  setUp(() async {
    p = await Process.start(
      'dart',
      ['run', 'bin/telegram_server.dart'],
      environment: {'PORT': port},
    );
    await p.stdout.first;
  });

  tearDown(() => p.kill());

  test('Get user', () async {
    final response = await get(Uri.parse('$host/user'), headers: headers);

    expect(response.statusCode, 200);
    final user = User.fromJson(
      jsonDecode(response.body) as Map<String, Object?>,
    );

    expect(user, Constants.user);
  });

  test('404', () async {
    final response = await get(Uri.parse('$host/foobar'), headers: headers);
    expect(response.statusCode, 404);
  });

  test('Login with valid credentials', () async {
    final response = await post(
      Uri.parse('$host/login'),
      body: jsonEncode(
        const LoginRequest(
          email: Constants.email,
          password: Constants.password,
        ),
      ),
    );
    expect(response.statusCode, 200);
    final loginResponse = LoginResponse.fromJson(
      jsonDecode(response.body) as Map<String, Object?>,
    );
    expect(loginResponse.token, Constants.token);
    expect(loginResponse.user, Constants.user);
  });

  test('Login with wrong credentials', () async {
    final response = await post(
      Uri.parse('$host/login'),
      body: jsonEncode(
        const LoginRequest(email: 'INVALID', password: 'INVALID'),
      ),
    );
    expect(response.statusCode, 401);
  });
}
