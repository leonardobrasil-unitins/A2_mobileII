import 'package:ecommerce_app/controllers/base_controller.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:ecommerce_app/services/order_service.dart';

class ProfileController extends BaseController {
  ProfileController({
    OrderService? orderService,
  }) : _orderService = orderService ?? OrderService();

  final OrderService _orderService;

  List<OrderModel> _orders = const [];
  int? _loadedUserId;

  List<OrderModel> get orders => List.unmodifiable(_orders);
  bool get hasOrders => _orders.isNotEmpty;
  int get totalOrders => _orders.length;
  int get waitingOrders => _orders.where((order) => order.payment == null).length;
  double get totalSpent => _orders.fold(0.0, (total, order) => total + order.total);
  OrderModel? get latestOrder => _orders.isEmpty ? null : _orders.first;

  Future<void> loadProfile(UserModel user, {bool forceRefresh = false}) async {
    if (!forceRefresh && _loadedUserId == user.id && (_orders.isNotEmpty || isLoading)) {
      return;
    }

    _loadedUserId = user.id;

    await execute(() async {
      final orders = await _orderService.getOrdersByClient(user.id);
      _orders = orders;
      notifyListeners();
    }, fallbackError: 'Nao foi possivel carregar seu perfil agora.');
  }
}
