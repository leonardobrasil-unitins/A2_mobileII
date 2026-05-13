import 'package:ecommerce_app/models/product_model.dart';

class OrderItemModel {
  const OrderItemModel({
    required this.quantity,
    required this.price,
    required this.subTotal,
    required this.product,
  });

  final int quantity;
  final double price;
  final double subTotal;
  final ProductModel product;

  factory OrderItemModel.fromProduct(
    ProductModel product, {
    int quantity = 1,
  }) {
    return OrderItemModel(
      quantity: quantity,
      price: product.price,
      subTotal: product.price * quantity,
      product: product,
    );
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      quantity: (map['quantity'] as num).toInt(),
      price: (map['price'] as num).toDouble(),
      subTotal: (map['subTotal'] as num).toDouble(),
      product: ProductModel.fromMap(map['product'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quantity': quantity,
      'price': price,
      'subTotal': subTotal,
      'product': product.toMap(),
    };
  }

  OrderItemModel copyWith({
    int? quantity,
    double? price,
    ProductModel? product,
  }) {
    final nextQuantity = quantity ?? this.quantity;
    final nextPrice = price ?? this.price;
    final nextProduct = product ?? this.product;

    return OrderItemModel(
      quantity: nextQuantity,
      price: nextPrice,
      subTotal: nextPrice * nextQuantity,
      product: nextProduct,
    );
  }
}
