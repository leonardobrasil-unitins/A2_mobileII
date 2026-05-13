import 'package:ecommerce_app/controllers/base_controller.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:ecommerce_app/services/auth_service.dart';

class RegisterController extends BaseController {
  RegisterController({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  Future<UserModel?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        phone.trim().isEmpty ||
        password.trim().isEmpty ||
        confirmPassword.trim().isEmpty) {
      setErrorMessage('Preencha todos os campos para criar sua conta.');
      return null;
    }

    if (password != confirmPassword) {
      setErrorMessage('As senhas nao coincidem.');
      return null;
    }

    UserModel? createdUser;

    await execute(() async {
      createdUser = await _authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
    }, fallbackError: 'Nao foi possivel concluir seu cadastro.');

    return createdUser;
  }
}
