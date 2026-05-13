import 'dart:convert';

import 'package:ecommerce_app/models/order_item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  Future<List<OrderItemModel>> restoreCart({required int userId}) async {
    final preferences = await SharedPreferences.getInstance();
    final rawCart = preferences.getString(_cartKey(userId));

    if (rawCart == null || rawCart.isEmpty) {
      return const [];
    }

    final data = jsonDecode(rawCart) as List<dynamic>;

    return data
        .cast<Map<String, dynamic>>()
        .map(OrderItemModel.fromMap)
        .toList();
  }

  Future<void> saveCart({
    required int userId,
    required List<OrderItemModel> items,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _cartKey(userId),
      jsonEncode(items.map((item) => item.toMap()).toList()),
    );
  }

  Future<void> clearCart({required int userId}) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_cartKey(userId));
  }

  String _cartKey(int userId) => 'cart_items_user_$userId';
}
