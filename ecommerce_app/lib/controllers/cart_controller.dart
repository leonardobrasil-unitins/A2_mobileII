import 'package:ecommerce_app/controllers/base_controller.dart';
import 'package:ecommerce_app/models/order_item_model.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:ecommerce_app/services/cart_service.dart';

class CartController extends BaseController {
  CartController({CartService? cartService})
      : _cartService = cartService ?? CartService();

  final CartService _cartService;

  int? _userId;
  List<OrderItemModel> _items = const [];

  List<OrderItemModel> get items => List.unmodifiable(_items);
  bool get hasItems => _items.isNotEmpty;
  int get totalItems =>
      _items.fold(0, (total, item) => total + item.quantity);
  double get totalAmount =>
      _items.fold(0.0, (total, item) => total + item.subTotal);

  Future<void> attachUser(UserModel? user) async {
    final nextUserId = user?.id;

    if (_userId == nextUserId) {
      return;
    }

    _userId = nextUserId;

    if (_userId == null) {
      _items = const [];
      notifyListeners();
      return;
    }

    setLoading(true);

    try {
      _items = await _cartService.restoreCart(userId: _userId!);
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> addProduct(ProductModel product) async {
    if (_userId == null) {
      return;
    }

    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      final currentItem = _items[existingIndex];
      _items = List<OrderItemModel>.from(_items)
        ..[existingIndex] = currentItem.copyWith(
          quantity: currentItem.quantity + 1,
        );
    } else {
      _items = List<OrderItemModel>.from(_items)
        ..add(OrderItemModel.fromProduct(product));
    }

    notifyListeners();
    await _persistCart();
  }

  Future<void> increaseQuantity(OrderItemModel item) async {
    await _updateQuantity(item: item, quantity: item.quantity + 1);
  }

  Future<void> decreaseQuantity(OrderItemModel item) async {
    final nextQuantity = item.quantity - 1;

    if (nextQuantity <= 0) {
      await removeItem(item);
      return;
    }

    await _updateQuantity(item: item, quantity: nextQuantity);
  }

  Future<void> removeItem(OrderItemModel item) async {
    _items = _items.where((currentItem) {
      return currentItem.product.id != item.product.id;
    }).toList();

    notifyListeners();
    await _persistCart();
  }

  Future<void> clearCurrentCart() async {
    if (_userId == null) {
      _items = const [];
      notifyListeners();
      return;
    }

    _items = const [];
    notifyListeners();
    await _cartService.clearCart(userId: _userId!);
  }

  Future<void> _updateQuantity({
    required OrderItemModel item,
    required int quantity,
  }) async {
    final index = _items.indexWhere(
      (currentItem) => currentItem.product.id == item.product.id,
    );

    if (index < 0) {
      return;
    }

    _items = List<OrderItemModel>.from(_items)
      ..[index] = item.copyWith(quantity: quantity);

    notifyListeners();
    await _persistCart();
  }

  Future<void> _persistCart() async {
    if (_userId == null) {
      return;
    }

    await _cartService.saveCart(userId: _userId!, items: _items);
  }
}
