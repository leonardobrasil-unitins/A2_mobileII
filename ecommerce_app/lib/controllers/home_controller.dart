import 'package:ecommerce_app/controllers/base_controller.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/services/product_service.dart';

class HomeController extends BaseController {
  HomeController({
    ProductService? productService,
  }) : _productService = productService ?? ProductService();

  final ProductService _productService;

  List<ProductModel> _featuredProducts = const [];
  String _searchQuery = '';

  String get searchQuery => _searchQuery;
  List<ProductModel> get featuredProducts => List.unmodifiable(_featuredProducts);

  List<ProductModel> get visibleProducts {
    return featuredProducts.where(_matchesFilters).toList();
  }

  Future<void> loadHomeData() async {
    await execute(() async {
      final products = await _productService.getFeaturedProducts();

      _featuredProducts = products;
      notifyListeners();
    });
  }

  void updateSearchQuery(String value) {
    final normalizedValue = value.trim();

    if (_searchQuery == normalizedValue) {
      return;
    }

    _searchQuery = normalizedValue;
    notifyListeners();
  }

  bool _matchesFilters(ProductModel product) {
    if (_searchQuery.isEmpty) {
      return true;
    }

    final normalizedQuery = _searchQuery.toLowerCase();
    final matchesName = product.name.toLowerCase().contains(normalizedQuery);
    final matchesCategoryName = product.categories.any(
      (category) => category.name.toLowerCase().contains(normalizedQuery),
    );

    return matchesName || matchesCategoryName;
  }
}
