import 'dart:convert';

import 'package:ecommerce_app/models/checkout_draft_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutPreferencesService {
  static const _draftPrefix = 'checkout_draft_';

  Future<CheckoutDraftModel> restoreDraft({required int userId}) async {
    final preferences = await SharedPreferences.getInstance();
    final rawDraft = preferences.getString('$_draftPrefix$userId');

    if (rawDraft == null || rawDraft.isEmpty) {
      return const CheckoutDraftModel();
    }

    final data = jsonDecode(rawDraft) as Map<String, dynamic>;
    return CheckoutDraftModel.fromMap(data);
  }

  Future<void> saveDraft({
    required int userId,
    required CheckoutDraftModel draft,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      '$_draftPrefix$userId',
      jsonEncode(draft.toMap()),
    );
  }

  Future<void> clearDraft({required int userId}) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('$_draftPrefix$userId');
  }
}
