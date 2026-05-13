import 'package:ecommerce_app/controllers/base_controller.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:ecommerce_app/services/auth_service.dart';

class SessionController extends BaseController {
  SessionController({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;

  UserModel? _currentUser;
  bool _isInitialized = false;

  UserModel? get currentUser => _currentUser;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _currentUser != null;

  Future<void> restoreSession() async {
    if (_isInitialized) {
      return;
    }

    setLoading(true);

    try {
      _currentUser = await _authService.restoreSession();
    } finally {
      _isInitialized = true;
      setLoading(false);
      notifyListeners();
    }
  }

  void startSession(UserModel user) {
    _currentUser = user;
    _isInitialized = true;
    setErrorMessage(null);
    notifyListeners();
  }

  Future<void> signOut() async {
    await execute(() async {
      await _authService.logout();
      _currentUser = null;
      notifyListeners();
    }, fallbackError: 'Nao foi possivel encerrar a sessao.');
  }
}
