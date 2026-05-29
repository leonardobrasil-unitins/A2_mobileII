import 'package:ecommerce_app/controllers/base_controller.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:ecommerce_app/services/order_service.dart';

class OrdersController extends BaseController {
  OrdersController({OrderService? orderService})
      : _orderService = orderService ?? OrderService();

  final OrderService _orderService;

  List<OrderModel> _orders = const [];

  List<OrderModel> get orders => List.unmodifiable(_orders);
  bool get hasOrders => _orders.isNotEmpty;

  Future<void> loadOrdersForUser(UserModel user) async {
    await execute(() async {
      _orders = await _orderService.getOrdersByClient(user.id);
      notifyListeners();
    }, fallbackError: 'Nao foi possivel carregar seus pedidos.');
  }
}
