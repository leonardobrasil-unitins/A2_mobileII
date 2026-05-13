import 'package:ecommerce_app/models/category_model.dart';

class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imgUrl,
    required this.categories,
  });

  final int id;
  final String name;
  final String description;
  final double price;
  final String imgUrl;
  final List<CategoryModel> categories;

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    final categories = (map['categories'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map(CategoryModel.fromMap)
        .toList();

    return ProductModel(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      imgUrl: map['imgUrl'] as String? ?? '',
      categories: categories,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imgUrl': imgUrl,
      'categories': categories.map((category) => category.toMap()).toList(),
    };
  }
}
