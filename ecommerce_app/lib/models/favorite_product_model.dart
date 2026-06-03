import 'package:ecommerce_app/models/product_model.dart';

class FavoriteProductModel {
  const FavoriteProductModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.productImgUrl,
    required this.productPrice,
    required this.createdAt,
  });

  final int id;
  final int userId;
  final int productId;
  final String productName;
  final String productImgUrl;
  final double productPrice;
  final DateTime createdAt;

  factory FavoriteProductModel.fromProduct({
    required int userId,
    required ProductModel product,
  }) {
    return FavoriteProductModel(
      id: 0,
      userId: userId,
      productId: product.id,
      productName: product.name,
      productImgUrl: product.imgUrl,
      productPrice: product.price,
      createdAt: DateTime.now(),
    );
  }

  factory FavoriteProductModel.fromMap(Map<String, dynamic> map) {
    return FavoriteProductModel(
      id: (map['id'] as num).toInt(),
      userId: (map['app_user_id'] as num).toInt(),
      productId: (map['product_id'] as num).toInt(),
      productName: map['product_name'] as String? ?? '',
      productImgUrl: map['product_img_url'] as String? ?? '',
      productPrice: (map['product_price'] as num? ?? 0).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'app_user_id': userId,
      'product_id': productId,
      'product_name': productName,
      'product_img_url': productImgUrl,
      'product_price': productPrice,
    };
  }

  ProductModel toProductModel() {
    return ProductModel(
      id: productId,
      name: productName,
      description: 'Produto salvo nos seus favoritos.',
      price: productPrice,
      imgUrl: productImgUrl,
      categories: const [],
    );
  }
}
