import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:telegram_frontend/config/api_config.dart';
import 'package:telegram_frontend/data/repositories/auth/auth_repository.dart';
import 'package:telegram_frontend/data/repositories/auth/auth_repository_remote.dart';
import 'package:telegram_frontend/data/repositories/chat/chat_repository.dart';
import 'package:telegram_frontend/data/repositories/chat/chat_repository_remote.dart';
import 'package:telegram_frontend/data/repositories/message/message_repository.dart';
import 'package:telegram_frontend/data/repositories/message/message_repository_remote.dart';
import 'package:telegram_frontend/data/repositories/story/story_repository.dart';
import 'package:telegram_frontend/data/repositories/story/story_repository_remote.dart';
import 'package:telegram_frontend/data/services/api/api_client.dart';
import 'package:telegram_frontend/data/services/api/auth_api_client.dart';
import 'package:telegram_frontend/data/services/share_preference_service.dart';
import 'package:telegram_frontend/data/services/websocket_service.dart';
import 'package:telegram_frontend/l10n/l10n.dart';
import 'package:telegram_frontend/routing/routes.dart';
import 'package:telegram_frontend/ui/cubit/auth/auth_cubit.dart';
import 'package:telegram_frontend/ui/views/auth/login/login_screen.dart';
import 'package:telegram_frontend/ui/views/groups/cubit/groups_cubit.dart';
import 'package:telegram_frontend/ui/views/groups/groups_screen.dart';
import 'package:telegram_frontend/ui/views/nav/nav.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiClient>(
          create: (context) => ApiClient(
            baseUrl: ApiConfig.baseUrl,
          ),
        ),
        RepositoryProvider<AuthApiClient>(
          create: (context) => AuthApiClient(
            baseUrl: ApiConfig.baseUrl,
          ),
        ),
        RepositoryProvider<SharedPreferencesService>(
          create: (context) => SharedPreferencesService(),
        ),
        RepositoryProvider<WebSocketService>(
          create: (context) => WebSocketService(),
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryRemote(
            apiClient: context.read<ApiClient>(),
            authApiClient: context.read<AuthApiClient>(),
            sharedPreferencesService: context.read<SharedPreferencesService>(),
          ),
        ),
        RepositoryProvider<ChatRepository>(
          create: (context) => ChatRepositoryRemote(
            apiClient: context.read<ApiClient>(),
          ),
        ),
        RepositoryProvider<StoryRepository>(
          create: (context) => StoryRepositoryRemote(
            apiClient: context.read<ApiClient>(),
          ),
        ),
        RepositoryProvider<MessageRepository>(
          create: (context) => MessageRepositoryRemote(
            apiClient: context.read<ApiClient>(),
            webSocketService: context.read<WebSocketService>(),
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          final authRepository = context.read<AuthRepository>();

          return MultiBlocProvider(
            providers: [
              BlocProvider<AuthCubit>(
                create: (context) => AuthCubit(
                  authRepository: authRepository,
                )..checkAuthStatus(),
              ),
              BlocProvider<NavCubit>(
                create: (context) => NavCubit(
                  authRepository: authRepository,
                ),
              ),
            ],
            child: MaterialApp(
              title: 'Telegram',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                useMaterial3: true,
              ),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              initialRoute: '/',
              routes: {
                '/': (context) => const _AuthGuard(),
                Routes.login: (context) => const LoginScreen(),
                Routes.home: (context) => const NavScreen(),
              },
              onGenerateRoute: (settings) {
                if (settings.name == Routes.chat) {
                  final args = settings.arguments as Map<String, String>?;
                  final chatId = args?['chatId'] ?? 'chat_001';
                  final chatName = args?['chatName'] ?? 'Chat';
                  final profilePicture = args?['profilePicture'] ?? '';

                  return MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => GroupsCubit(
                        messageRepository: context.read<MessageRepository>(),
                        navCubit: context.read<NavCubit>(),
                      )..initialize(chatId),
                      child: GroupsScreen(
                        chatId: chatId,
                        chatName: chatName,
                        profilePicture: profilePicture,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          );
        },
      ),
    );
  }
}

class _AuthGuard extends StatelessWidget {
  const _AuthGuard();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status != FormzSubmissionStatus.inProgress) {
          if (state.isAuthenticated) {
            Navigator.of(context).pushReplacementNamed(Routes.home);
          } else {
            Navigator.of(context).pushReplacementNamed(Routes.login);
          }
        }
      },
      builder: (context, state) {
        return const Scaffold(
          backgroundColor: Colors.blue,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Telegram',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 32),
                CircularProgressIndicator(
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
