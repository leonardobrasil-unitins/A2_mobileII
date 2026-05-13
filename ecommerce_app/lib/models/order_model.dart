import 'package:ecommerce_app/models/order_item_model.dart';
import 'package:ecommerce_app/models/order_status.dart';
import 'package:ecommerce_app/models/payment_model.dart';
import 'package:ecommerce_app/models/user_model.dart';

class OrderModel {
  const OrderModel({
    required this.id,
    required this.moment,
    required this.client,
    required this.items,
    required this.orderStatus,
    required this.payment,
    required this.total,
  });

  final int id;
  final DateTime moment;
  final UserModel client;
  final List<OrderItemModel> items;
  final OrderStatus orderStatus;
  final PaymentModel? payment;
  final double total;

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    final items = (map['items'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map(OrderItemModel.fromMap)
        .toList();

    return OrderModel(
      id: (map['id'] as num).toInt(),
      moment: DateTime.parse(map['moment'] as String),
      client: UserModel.fromMap(map['client'] as Map<String, dynamic>),
      items: items,
      orderStatus: OrderStatus.fromApiValue(map['orderStatus'] as String),
      payment: map['payment'] == null
          ? null
          : PaymentModel.fromMap(map['payment'] as Map<String, dynamic>),
      total: (map['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'moment': moment.toUtc().toIso8601String(),
      'client': client.toMap(),
      'items': items.map((item) => item.toMap()).toList(),
      'orderStatus': orderStatus.apiValue,
      'payment': payment?.toMap(),
      'total': total,
    };
  }
}
