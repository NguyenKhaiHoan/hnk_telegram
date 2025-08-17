import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../config/assets.dart';
import '../model/story/story.dart';

class StoryRoutes {
  Router get router {
    final router =
        Router()
          ..get('/', (Request request) async {
            try {
              final storiesJson = await Assets.loadJsonFile('stories.json');
              final stories =
                  (storiesJson as List)
                      .map((json) => Story.fromJson(json))
                      .toList();

              return Response.ok(
                jsonEncode(stories.map((s) => s.toJson()).toList()),
                headers: {'content-type': 'application/json'},
              );
            } catch (e) {
              return Response.internalServerError(
                body: jsonEncode({'error': 'Failed to load stories: $e'}),
                headers: {'content-type': 'application/json'},
              );
            }
          })
          ..get('/active', (Request request) async {
            try {
              final storiesJson = await Assets.loadJsonFile('stories.json');
              final _ = DateTime.now();
              final activeStories =
                  (storiesJson as List)
                      .map((json) => Story.fromJson(json))
                      .where((story) {
                        if (!story.isActive) return false;
                        // final expiresAt = DateTime.parse(story.expiresAt);
                        // return expiresAt.isAfter(now);
                        return true;
                      })
                      .toList();

              return Response.ok(
                jsonEncode(activeStories.map((s) => s.toJson()).toList()),
                headers: {'content-type': 'application/json'},
              );
            } catch (e) {
              return Response.internalServerError(
                body: jsonEncode({
                  'error': 'Failed to load active stories: $e',
                }),
                headers: {'content-type': 'application/json'},
              );
            }
          })
          ..get('/user/<userId>', (Request request, String userId) async {
            try {
              final storiesJson = await Assets.loadJsonFile('stories.json');
              final stories =
                  (storiesJson as List)
                      .map((json) => Story.fromJson(json))
                      .where(
                        (story) => story.userId == userId && story.isActive,
                      )
                      .toList();

              return Response.ok(
                jsonEncode(stories.map((s) => s.toJson()).toList()),
                headers: {'content-type': 'application/json'},
              );
            } catch (e) {
              return Response.internalServerError(
                body: jsonEncode({
                  'error': 'Failed to load stories of user: $e',
                }),
                headers: {'content-type': 'application/json'},
              );
            }
          })
          ..get('/<storyId>', (Request request, String storyId) async {
            try {
              final storiesJson = await Assets.loadJsonFile('stories.json');
              final story =
                  (storiesJson as List)
                      .map((json) => Story.fromJson(json))
                      .where((story) => story.id == storyId && story.isActive)
                      .firstOrNull;

              if (story == null) {
                return Response.notFound(
                  jsonEncode({'error': 'Không tìm thấy story'}),
                  headers: {'content-type': 'application/json'},
                );
              }

              return Response.ok(
                jsonEncode(story.toJson()),
                headers: {'content-type': 'application/json'},
              );
            } catch (e) {
              return Response.internalServerError(
                body: jsonEncode({'error': 'Không thể tải story: $e'}),
                headers: {'content-type': 'application/json'},
              );
            }
          })
          ..post('/', (Request request) async {
            try {
              final body = await request.readAsString();
              final storyData = jsonDecode(body) as Map<String, dynamic>;

              if (!storyData.containsKey('user_id') ||
                  !storyData.containsKey('story_picture') ||
                  !storyData.containsKey('user_name')) {
                return Response.badRequest(
                  body: jsonEncode({
                    'error':
                        'Missing required fields: user_id, story_picture, user_name',
                  }),
                  headers: {'content-type': 'application/json'},
                );
              }

              final storiesJson = await Assets.loadJsonFile('stories.json');
              final stories =
                  (storiesJson as List).cast<Map<String, dynamic>>();

              final newStory = {
                'id': 'story_${stories.length + 1}',
                'user_id': storyData['user_id'],
                'user_name': storyData['user_name'],
                'user_profile_picture': storyData['user_profile_picture'] ?? '',
                'story_picture': storyData['story_picture'],
                'caption': storyData['caption'] ?? '',
                'created_at': DateTime.now().toIso8601String(),
                'expires_at':
                    DateTime.now().add(Duration(hours: 24)).toIso8601String(),
                'is_active': true,
                'view_count': 0,
              };

              stories.add(newStory);
              await Assets.saveJsonFile('stories.json', stories);

              return Response.ok(
                jsonEncode(newStory),
                headers: {'content-type': 'application/json'},
              );
            } catch (e) {
              return Response.internalServerError(
                body: jsonEncode({'error': 'Failed to create story: $e'}),
                headers: {'content-type': 'application/json'},
              );
            }
          })
          ..put('/<storyId>/view', (Request request, String storyId) async {
            try {
              final storiesJson = await Assets.loadJsonFile('stories.json');
              final stories =
                  (storiesJson as List).cast<Map<String, dynamic>>();

              final storyIndex = stories.indexWhere(
                (story) => story['id'] == storyId,
              );
              if (storyIndex == -1) {
                return Response.notFound(
                  jsonEncode({'error': 'Story not found'}),
                  headers: {'content-type': 'application/json'},
                );
              }

              stories[storyIndex]['viewCount'] =
                  (stories[storyIndex]['viewCount'] ?? 0) + 1;

              await Assets.saveJsonFile('stories.json', stories);

              return Response.ok(
                jsonEncode({
                  'message': 'View count updated',
                  'view_count': stories[storyIndex]['view_count'],
                }),
                headers: {'content-type': 'application/json'},
              );
            } catch (e) {
              return Response.internalServerError(
                body: jsonEncode({'error': 'Failed to update view count: $e'}),
                headers: {'content-type': 'application/json'},
              );
            }
          })
          ..delete('/<storyId>', (Request request, String storyId) async {
            try {
              final storiesJson = await Assets.loadJsonFile('stories.json');
              final stories =
                  (storiesJson as List).cast<Map<String, dynamic>>();

              final storyIndex = stories.indexWhere(
                (story) => story['id'] == storyId,
              );
              if (storyIndex == -1) {
                return Response.notFound(
                  jsonEncode({'error': 'Story not found'}),
                  headers: {'content-type': 'application/json'},
                );
              }

              stories[storyIndex]['isActive'] = false;

              await Assets.saveJsonFile('stories.json', stories);

              return Response.ok(
                jsonEncode({'message': 'Story deleted'}),
                headers: {'content-type': 'application/json'},
              );
            } catch (e) {
              return Response.internalServerError(
                body: jsonEncode({'error': 'Failed to delete story: $e'}),
                headers: {'content-type': 'application/json'},
              );
            }
          });

    return router;
  }
}
