import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../entities/profile_entity.dart';
import '../repositories/customer_repository.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.read(customerRepositoryProvider));
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
  final CustomerRepository _repository;
  AuthController(this._repository) : super(const Unauthenticated());

  bool isAuthenticated() => state is Authenticated;

  void signIn({required String email, required String password}) async {
    try {
      state = AuthLoading();

      final profile = await _repository.signIn(username: email, password: password);

      if (profile == null) {
        state = const Unauthenticated(message: "Usuario o contraseña inválidos.");
        return;
      }

      state = Authenticated(profile);
    } catch (e) {
      log(e.toString());
      state = const Unauthenticated(message: "Usuario o contraseña inválidos.");
    }
  }

  void signOut() async {
    state = const Unauthenticated();
  }
}
