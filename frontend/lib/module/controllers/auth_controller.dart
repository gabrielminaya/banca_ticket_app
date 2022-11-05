import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../entities/profile_entity.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController();
});

abstract class AuthState {
  const AuthState();
}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final ProfileEntity entity;

  const Authenticated(this.entity);
}

class Unauthenticated extends AuthState {
  final String? message;

  const Unauthenticated({this.message});
}

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const Unauthenticated());

  bool isAuthenticated() => state is Authenticated;

  void signIn({required String email, required String password}) async {
    try {
      state = AuthLoading();

      // if (result.user == null) {
      //   state = const Unauthenticated(message: "Usuario o contraseña inválidos.");
      //   return;
      // }

      state = Authenticated(
        ProfileEntity(),
      );
    } catch (e) {
      log(e.toString());
      state = const Unauthenticated(message: "Usuario o contraseña inválidos.");
    }
  }

  void signOut() async {
    state = const Unauthenticated();
  }
}
