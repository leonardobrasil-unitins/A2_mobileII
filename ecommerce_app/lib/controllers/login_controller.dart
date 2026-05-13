import 'package:ecommerce_app/controllers/base_controller.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:ecommerce_app/services/auth_service.dart';

class LoginController extends BaseController {
  LoginController({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;

  bool _obscurePassword = true;

  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      setErrorMessage('Preencha email e senha para entrar.');
      return null;
    }

    UserModel? authenticatedUser;

    await execute(() async {
      authenticatedUser = await _authService.login(
        email: email,
        password: password,
      );
    }, fallbackError: 'Nao foi possivel entrar agora.');

    return authenticatedUser;
  }
}
