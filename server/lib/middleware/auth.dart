import 'package:shelf/shelf.dart';

Middleware authRequests() => (innerHandler) {
  return (Request request) async {
    final publicPaths = ['', 'login', 'test', 'debug-assets'];
    final path = request.url.path;

    if (publicPaths.contains(path) || path.startsWith('test/')) {
      print('✅ Public path - allowing access');
      return innerHandler(request);
    }

    // Check authentication for protected endpoints
    final authHeader = request.headers['Authorization'];

    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return Response.unauthorized(
        'Unauthorized - Authentication required',
        headers: {'Content-Type': 'application/json'},
      );
    }

    return innerHandler(request);
  };
};
