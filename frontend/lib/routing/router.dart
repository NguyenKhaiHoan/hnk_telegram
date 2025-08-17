import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:telegram_frontend/data/repositories/auth/auth_repository.dart';
import 'package:telegram_frontend/routing/routes.dart';
import 'package:telegram_frontend/ui/views/auth/login/login_screen.dart';
import 'package:telegram_frontend/ui/views/nav/nav.dart';

GoRouter router(AuthRepository authRepository) => GoRouter(
      initialLocation: Routes.home,
      debugLogDiagnostics: true,
      redirect: (context, state) => _redirect(context, state, authRepository),
      refreshListenable: GoRouterRefreshStream(
        Stream.periodic(
          const Duration(seconds: 1),
          (_) => authRepository.isAuthenticated,
        ),
      ),
      routes: [
        GoRoute(
          path: Routes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: Routes.home,
          builder: (context, state) => BlocProvider<NavCubit>(
            create: (context) => NavCubit(
              authRepository: authRepository,
            )..initialize(),
            lazy: false,
            child: const NavScreen(),
          ),
        ),
      ],
    );

Future<String?> _redirect(
  BuildContext context,
  GoRouterState state,
  AuthRepository authRepository,
) async {
  final loggedIn = await authRepository.isAuthenticated;
  final loggingIn = state.matchedLocation == Routes.login;
  final currentPath = state.matchedLocation;

  if (!loggedIn && currentPath != Routes.login) {
    return Routes.login;
  }

  if (loggedIn && loggingIn) {
    return Routes.home;
  }

  return null;
}

/// GoRouter refresh stream for auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<Future<bool>> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (future) async {
        await future;
        notifyListeners();
      },
    );
  }

  late final StreamSubscription<Future<bool>> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
