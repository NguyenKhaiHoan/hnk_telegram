import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:telegram_frontend/config/api_config.dart';
import 'package:telegram_frontend/data/repositories/auth/auth_repository.dart';
import 'package:telegram_frontend/data/repositories/auth/auth_repository_remote.dart';
import 'package:telegram_frontend/data/repositories/chat/chat_repository.dart';
import 'package:telegram_frontend/data/repositories/chat/chat_repository_remote.dart';
import 'package:telegram_frontend/data/repositories/story/story_repository.dart';
import 'package:telegram_frontend/data/repositories/story/story_repository_remote.dart';
import 'package:telegram_frontend/data/services/api/api_client.dart';
import 'package:telegram_frontend/data/services/api/auth_api_client.dart';
import 'package:telegram_frontend/data/services/share_preference_service.dart';
import 'package:telegram_frontend/l10n/l10n.dart';
import 'package:telegram_frontend/routing/router.dart';
import 'package:telegram_frontend/ui/cubit/auth/auth_cubit.dart';

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
            ],
            child: MaterialApp.router(
              title: 'Telegram',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                useMaterial3: true,
              ),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              routerConfig: router(authRepository),
            ),
          );
        },
      ),
    );
  }
}
