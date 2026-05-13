import 'dart:convert';

import 'package:ecommerce_app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _currentUserKey = 'current_user_session';

  Future<UserModel?> restoreCurrentUser() async {
    final preferences = await SharedPreferences.getInstance();
    final rawUser = preferences.getString(_currentUserKey);

    if (rawUser == null || rawUser.isEmpty) {
      return null;
    }

    final data = jsonDecode(rawUser) as Map<String, dynamic>;
    return UserModel.fromMap(data);
  }

  Future<void> saveCurrentUser(UserModel user) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _currentUserKey,
      jsonEncode(user.toSessionMap()),
    );
  }

  Future<void> clearCurrentUser() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_currentUserKey);
  }
}
