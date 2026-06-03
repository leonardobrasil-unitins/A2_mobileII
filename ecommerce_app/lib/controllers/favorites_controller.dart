import 'package:ecommerce_app/controllers/base_controller.dart';
import 'package:ecommerce_app/core/errors/app_exception.dart';
import 'package:ecommerce_app/models/favorite_product_model.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:ecommerce_app/services/favorite_service.dart';

class FavoritesController extends BaseController {
  FavoritesController({
    FavoriteService? favoriteService,
  }) : _favoriteService = favoriteService ?? FavoriteService();

  final FavoriteService _favoriteService;

  int? _userId;
  List<FavoriteProductModel> _favorites = const [];

  List<FavoriteProductModel> get favorites => List.unmodifiable(_favorites);
  bool get hasFavorites => _favorites.isNotEmpty;
  bool get isSupabaseConfigured => _favoriteService.isConfigured;
  int get totalFavorites => _favorites.length;

  Set<int> get favoriteProductIds {
    return _favorites.map((favorite) => favorite.productId).toSet();
  }

  bool isFavorite(int productId) {
    return _favorites.any((favorite) => favorite.productId == productId);
  }

  Future<void> attachUser(UserModel? user) async {
    final nextUserId = user?.id;

    if (_userId == nextUserId) {
      return;
    }

    _userId = nextUserId;

    if (_userId == null) {
      _favorites = const [];
      notifyListeners();
      return;
    }

    await refreshFavorites();
  }

  Future<void> refreshFavorites() async {
    if (_userId == null) {
      _favorites = const [];
      notifyListeners();
      return;
    }

    await execute(() async {
      _favorites = await _favoriteService.getFavoritesByUser(_userId!);
      notifyListeners();
    }, fallbackError: 'Nao foi possivel atualizar seus favoritos.');
  }

  Future<void> toggleFavorite({
    required UserModel? user,
    required ProductModel product,
  }) async {
    if (user == null) {
      setErrorMessage('Entre novamente para sincronizar favoritos.');
      return;
    }

    if (!_favoriteService.isConfigured) {
      setErrorMessage(
        'Configure SUPABASE_URL e SUPABASE_ANON_KEY para usar favoritos.',
      );
      return;
    }

    setErrorMessage(null);
    setLoading(true);

    final wasFavorite = isFavorite(product.id);
    final previousFavorites = _favorites;

    try {
      if (wasFavorite) {
        _favorites = _favorites
            .where((favorite) => favorite.productId != product.id)
            .toList();
        notifyListeners();

        await _favoriteService.removeFavorite(
          userId: user.id,
          productId: product.id,
        );
      } else {
        _favorites = [
          FavoriteProductModel.fromProduct(userId: user.id, product: product),
          ..._favorites,
        ];
        notifyListeners();

        await _favoriteService.addFavorite(user: user, product: product);
      }
    } on AppException catch (error) {
      _favorites = previousFavorites;
      setErrorMessage(error.message);
      notifyListeners();
    } catch (_) {
      _favorites = previousFavorites;
      setErrorMessage('Nao foi possivel sincronizar esse favorito.');
      notifyListeners();
    } finally {
      setLoading(false);
    }
  }
}
