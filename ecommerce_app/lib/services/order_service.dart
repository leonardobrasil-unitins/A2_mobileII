import 'package:ecommerce_app/models/order_item_model.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:ecommerce_app/services/api_client_service.dart';

class OrderService {
  OrderService({ApiClientService? apiClient})
      : _apiClient = apiClient ?? ApiClientService();

  final ApiClientService _apiClient;

  Future<List<OrderModel>> getOrdersByClient(int clientId) async {
    final data = await _apiClient.getList('/orders/client/$clientId');

    return data.cast<Map<String, dynamic>>().map(OrderModel.fromMap).toList();
  }

  Future<OrderModel> checkout({
    required UserModel user,
    required List<OrderItemModel> items,
  }) async {
    final data = await _apiClient.postMap(
      '/orders',
      body: {
        'clientId': user.id,
        'items': items
            .map(
              (item) => {
                'productId': item.product.id,
                'quantity': item.quantity,
              },
            )
            .toList(),
      },
    );

    return OrderModel.fromMap(data);
  }
}
