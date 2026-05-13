import 'package:ecommerce_app/core/errors/app_exception.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:ecommerce_app/services/session_service.dart';
import 'package:ecommerce_app/services/user_service.dart';

class AuthService {
  AuthService({
    UserService? userService,
    SessionService? sessionService,
  })  : _userService = userService ?? UserService(),
        _sessionService = sessionService ?? SessionService();

  final UserService _userService;
  final SessionService _sessionService;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final users = await _userService.getUsers();
    final normalizedEmail = email.trim().toLowerCase();

    UserModel? authenticatedUser;

    for (final user in users) {
      final matchesEmail = user.email.trim().toLowerCase() == normalizedEmail;
      final matchesPassword = user.password == password;

      if (matchesEmail && matchesPassword) {
        authenticatedUser = user;
        break;
      }
    }

    if (authenticatedUser == null) {
      throw const AppException('Email ou senha invalidos.');
    }

    await _sessionService.saveCurrentUser(authenticatedUser);
    return authenticatedUser;
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final users = await _userService.getUsers();
    final normalizedEmail = email.trim().toLowerCase();

    final emailAlreadyUsed = users.any(
      (user) => user.email.trim().toLowerCase() == normalizedEmail,
    );

    if (emailAlreadyUsed) {
      throw const AppException('Ja existe uma conta cadastrada com esse email.');
    }

    final createdUser = await _userService.createUser(
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      password: password,
    );

    await _sessionService.saveCurrentUser(createdUser);
    return createdUser;
  }

  Future<UserModel?> restoreSession() {
    return _sessionService.restoreCurrentUser();
  }

  Future<void> logout() {
    return _sessionService.clearCurrentUser();
  }
}
