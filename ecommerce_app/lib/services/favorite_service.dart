import 'package:ecommerce_app/core/config/supabase_config.dart';
import 'package:ecommerce_app/core/errors/app_exception.dart';
import 'package:ecommerce_app/models/favorite_product_model.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/models/user_model.dart';
import 'package:supabase/supabase.dart';

class FavoriteService {
  FavoriteService({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  bool get isConfigured => SupabaseConfig.isConfigured;

  SupabaseClient get _supabase {
    if (_client != null) {
      return _client;
    }

    if (!SupabaseConfig.isConfigured) {
      throw const AppException(
        'Configure SUPABASE_URL e SUPABASE_ANON_KEY para sincronizar favoritos.',
      );
    }

    return SupabaseClient(
      SupabaseConfig.url,
      SupabaseConfig.publishableKey,
    );
  }

  Future<List<FavoriteProductModel>> getFavoritesByUser(int userId) async {
    if (!isConfigured) {
      return const [];
    }

    try {
      final data = await _supabase
          .from(SupabaseConfig.favoritesTable)
          .select()
          .eq('app_user_id', userId)
          .order('created_at', ascending: false);

      return data
          .cast<Map<String, dynamic>>()
          .map(FavoriteProductModel.fromMap)
          .toList();
    } catch (_) {
      throw const AppException(
        'Nao foi possivel carregar favoritos do Supabase.',
      );
    }
  }

  Future<void> addFavorite({
    required UserModel user,
    required ProductModel product,
  }) async {
    try {
      final favorite = FavoriteProductModel.fromProduct(
        userId: user.id,
        product: product,
      );

      await _supabase
          .from(SupabaseConfig.favoritesTable)
          .upsert(
            favorite.toSupabaseMap(),
            onConflict: 'app_user_id,product_id',
          );
    } catch (error) {
      if (error is AppException) {
        rethrow;
      }

      throw const AppException(
        'Nao foi possivel salvar esse favorito no Supabase.',
      );
    }
  }

  Future<void> removeFavorite({
    required int userId,
    required int productId,
  }) async {
    try {
      await _supabase
          .from(SupabaseConfig.favoritesTable)
          .delete()
          .eq('app_user_id', userId)
          .eq('product_id', productId);
    } catch (error) {
      if (error is AppException) {
        rethrow;
      }

      throw const AppException(
        'Nao foi possivel remover esse favorito no Supabase.',
      );
    }
  }
}
