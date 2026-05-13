import 'package:ecommerce_app/core/errors/app_exception.dart';
import 'package:flutter/foundation.dart';

abstract class BaseController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  @protected
  void setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;
    notifyListeners();
  }

  @protected
  void setErrorMessage(String? value) {
    if (_errorMessage == value) {
      return;
    }

    _errorMessage = value;
    notifyListeners();
  }

  @protected
  Future<void> execute(
    Future<void> Function() action, {
    String fallbackError = 'Nao foi possivel carregar os dados.',
  }) async {
    setErrorMessage(null);
    setLoading(true);

    try {
      await action();
    } on AppException catch (error) {
      setErrorMessage(error.message);
    } catch (_) {
      setErrorMessage(fallbackError);
    } finally {
      setLoading(false);
    }
  }
}
