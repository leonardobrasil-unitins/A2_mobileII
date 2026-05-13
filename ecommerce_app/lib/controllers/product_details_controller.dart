import 'package:ecommerce_app/controllers/base_controller.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/services/product_service.dart';

class ProductDetailsController extends BaseController {
  ProductDetailsController({
    required ProductModel initialProduct,
    ProductService? productService,
  })  : _product = initialProduct,
        _productService = productService ?? ProductService();

  final ProductService _productService;

  ProductModel _product;

  ProductModel get product => _product;

  Future<void> loadProductDetails() async {
    await execute(() async {
      final freshProduct = await _productService.getProductById(_product.id);
      _product = freshProduct;
      notifyListeners();
    }, fallbackError: 'Nao foi possivel carregar os detalhes do produto.');
  }
}
