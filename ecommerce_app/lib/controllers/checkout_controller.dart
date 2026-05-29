import 'package:ecommerce_app/controllers/base_controller.dart';
import 'package:ecommerce_app/models/checkout_draft_model.dart';
import 'package:ecommerce_app/models/checkout_payment_method.dart';
import 'package:ecommerce_app/services/checkout_preferences_service.dart';

class CheckoutController extends BaseController {
  CheckoutController({
    CheckoutPreferencesService? preferencesService,
  }) : _preferencesService =
           preferencesService ?? CheckoutPreferencesService();

  final CheckoutPreferencesService _preferencesService;

  CheckoutDraftModel _draft = const CheckoutDraftModel();
  int _currentStep = 0;
  int? _userId;

  CheckoutDraftModel get draft => _draft;
  int get currentStep => _currentStep;

  Future<void> restoreDraft({required int userId}) async {
    if (_userId == userId) {
      return;
    }

    _userId = userId;

    await execute(() async {
      _draft = await _preferencesService.restoreDraft(userId: userId);
      _currentStep = 0;
      notifyListeners();
    }, fallbackError: 'Nao foi possivel recuperar os dados do checkout.');
  }

  Future<void> clearDraft() async {
    if (_userId == null) {
      _draft = const CheckoutDraftModel();
      _currentStep = 0;
      notifyListeners();
      return;
    }

    _draft = const CheckoutDraftModel();
    _currentStep = 0;
    notifyListeners();
    await _preferencesService.clearDraft(userId: _userId!);
  }

  void goToStep(int value) {
    if (value < 0 || value > 2 || _currentStep == value) {
      return;
    }

    _currentStep = value;
    notifyListeners();
  }

  void nextStep() => goToStep(_currentStep + 1);

  void previousStep() => goToStep(_currentStep - 1);

  Future<void> updateZipCode(String value) async {
    await _saveDraft(_draft.copyWith(zipCode: value.trim()));
  }

  Future<void> updateStreet(String value) async {
    await _saveDraft(_draft.copyWith(street: value.trim()));
  }

  Future<void> updateNumber(String value) async {
    await _saveDraft(_draft.copyWith(number: value.trim()));
  }

  Future<void> updateNeighborhood(String value) async {
    await _saveDraft(_draft.copyWith(neighborhood: value.trim()));
  }

  Future<void> updateCity(String value) async {
    await _saveDraft(_draft.copyWith(city: value.trim()));
  }

  Future<void> updateState(String value) async {
    await _saveDraft(_draft.copyWith(state: value.trim()));
  }

  Future<void> updateComplement(String value) async {
    await _saveDraft(_draft.copyWith(complement: value.trim()));
  }

  Future<void> updateDeliveryInstructions(String value) async {
    await _saveDraft(_draft.copyWith(deliveryInstructions: value.trim()));
  }

  Future<void> updateDeliveryOption(CheckoutDeliveryOption value) async {
    await _saveDraft(_draft.copyWith(deliveryOption: value));
  }

  Future<void> updatePaymentMethod(CheckoutPaymentMethod value) async {
    await _saveDraft(_draft.copyWith(paymentMethod: value));
  }

  Future<void> _saveDraft(CheckoutDraftModel draft) async {
    _draft = draft;
    notifyListeners();

    if (_userId == null) {
      return;
    }

    await _preferencesService.saveDraft(userId: _userId!, draft: _draft);
  }
}
