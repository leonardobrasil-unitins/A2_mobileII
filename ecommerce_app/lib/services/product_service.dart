import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/services/api_client_service.dart';

class ProductService {
  ProductService({ApiClientService? apiClient})
      : _apiClient = apiClient ?? ApiClientService();

  final ApiClientService _apiClient;

  Future<List<ProductModel>> getFeaturedProducts() async {
    final data = await _apiClient.getList('/products');

    return data
        .cast<Map<String, dynamic>>()
        .map(ProductModel.fromMap)
        .toList();
  }

  Future<ProductModel> getProductById(int id) async {
    final data = await _apiClient.getMap('/products/$id');
    return ProductModel.fromMap(data);
  }
}
