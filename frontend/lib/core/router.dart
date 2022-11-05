import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/module/views/home_view.dart';
import 'package:go_router/go_router.dart';

import '../module/controllers/auth_controller.dart';
import '../module/views/sign_in_view.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = GoRouterRefreshStream(
    ref.watch(authControllerProvider.notifier).stream,
  );

  ref.onDispose(() {
    listenable.dispose();
  });

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: "/signIn",
    refreshListenable: listenable,
    redirect: (context, state) {
      final authState = ref.watch(authControllerProvider);

      final areWeInSignInPage = ["/signIn"].contains(state.location);

      if (authState is Unauthenticated || authState is AuthLoading) {
        return areWeInSignInPage ? null : '/signIn';
      }

      if (areWeInSignInPage) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/signIn',
        builder: (context, state) {
          return SignInView();
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          return HomeView();
        },
      ),
    ],
  );
});
