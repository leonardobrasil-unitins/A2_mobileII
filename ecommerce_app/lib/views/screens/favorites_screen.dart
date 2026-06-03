import 'package:ecommerce_app/controllers/cart_controller.dart';
import 'package:ecommerce_app/controllers/favorites_controller.dart';
import 'package:ecommerce_app/controllers/session_controller.dart';
import 'package:ecommerce_app/core/theme/app_style.dart';
import 'package:ecommerce_app/models/favorite_product_model.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/views/screens/product_details_screen.dart';
import 'package:ecommerce_app/views/widgets/product_image_artwork.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
    required this.sessionController,
    required this.cartController,
    required this.favoritesController,
  });

  final SessionController sessionController;
  final CartController cartController;
  final FavoritesController favoritesController;

  Future<void> _addToCart(BuildContext context, ProductModel product) async {
    await cartController.addProduct(product);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} foi adicionado ao carrinho.')),
    );
  }

  void _openDetails(BuildContext context, ProductModel product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailsScreen(
          product: product,
          cartController: cartController,
          sessionController: sessionController,
          favoritesController: favoritesController,
        ),
      ),
    );
  }

  Future<void> _removeFavorite(
    FavoriteProductModel favorite,
  ) async {
    await favoritesController.toggleFavorite(
      user: sessionController.currentUser,
      product: favorite.toProductModel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
      ),
      body: AnimatedBuilder(
        animation: favoritesController,
        builder: (context, _) {
          if (!favoritesController.isSupabaseConfigured) {
            return const _SupabaseSetupView();
          }

          if (favoritesController.isLoading &&
              !favoritesController.hasFavorites) {
            return const Center(child: CircularProgressIndicator());
          }

          if (favoritesController.errorMessage != null &&
              !favoritesController.hasFavorites) {
            return _FavoritesErrorView(
              message: favoritesController.errorMessage!,
              onRetry: favoritesController.refreshFavorites,
            );
          }

          if (!favoritesController.hasFavorites) {
            return const _EmptyFavoritesView();
          }

          return RefreshIndicator(
            onRefresh: favoritesController.refreshFavorites,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppStyle.screenPadding,
              children: [
                _FavoritesHero(
                  totalFavorites: favoritesController.totalFavorites,
                ),
                const SizedBox(height: AppStyle.spacingLg),
                ...favoritesController.favorites.map(
                  (favorite) {
                    final product = favorite.toProductModel();
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppStyle.spacingMd,
                      ),
                      child: _FavoriteProductCard(
                        favorite: favorite,
                        onTap: () => _openDetails(context, product),
                        onAddToCart: () => _addToCart(context, product),
                        onRemove: () => _removeFavorite(favorite),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FavoritesHero extends StatelessWidget {
  const _FavoritesHero({required this.totalFavorites});

  final int totalFavorites;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppStyle.spacingLg),
      decoration: BoxDecoration(
        gradient: AppStyle.heroGradient,
        borderRadius: BorderRadius.circular(AppStyle.radiusLarge),
        boxShadow: AppStyle.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppStyle.spacingSm,
              vertical: AppStyle.spacingXs,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$totalFavorites produto(s) salvo(s)',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppStyle.spacingLg),
          Text(
            'Sua vitrine particular.',
            style: textTheme.displayMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppStyle.spacingSm),
          Text(
            'Os produtos favoritados ficam sincronizados no Supabase.',
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteProductCard extends StatelessWidget {
  const _FavoriteProductCard({
    required this.favorite,
    required this.onTap,
    required this.onAddToCart,
    required this.onRemove,
  });

  final FavoriteProductModel favorite;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final product = favorite.toProductModel();

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppStyle.radiusMedium),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppStyle.spacingLg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 92,
                height: 92,
                child: ProductImageArtwork(
                  product: product,
                  iconSize: 34,
                  borderRadius: BorderRadius.circular(
                    AppStyle.radiusMedium,
                  ),
                ),
              ),
              const SizedBox(width: AppStyle.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(favorite.productName, style: textTheme.titleLarge),
                    const SizedBox(height: AppStyle.spacingXs),
                    Text(
                      'Salvo em ${_formatDate(favorite.createdAt)}',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppStyle.spacingMd),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatPrice(favorite.productPrice),
                            style: textTheme.titleLarge?.copyWith(
                              color: AppStyle.primaryColor,
                            ),
                          ),
                        ),
                        IconButton.filledTonal(
                          tooltip: 'Remover favorito',
                          onPressed: onRemove,
                          icon: const Icon(Icons.favorite_rounded),
                        ),
                        const SizedBox(width: AppStyle.spacingXs),
                        FilledButton(
                          onPressed: onAddToCart,
                          child: const Text('Adicionar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    final fixedValue = price.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $fixedValue';
  }

  String _formatDate(DateTime dateTime) {
    final localDateTime = dateTime.toLocal();
    final day = localDateTime.day.toString().padLeft(2, '0');
    final month = localDateTime.month.toString().padLeft(2, '0');
    final year = localDateTime.year;
    return '$day/$month/$year';
  }
}

class _SupabaseSetupView extends StatelessWidget {
  const _SupabaseSetupView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppStyle.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_sync_outlined,
              size: 64,
              color: AppStyle.primaryColor,
            ),
            const SizedBox(height: AppStyle.spacingMd),
            Text(
              'Supabase ainda nao configurado.',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppStyle.spacingSm),
            Text(
              'Passe SUPABASE_URL e SUPABASE_ANON_KEY no flutter run para sincronizar favoritos.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesErrorView extends StatelessWidget {
  const _FavoritesErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppStyle.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.favorite_border_rounded,
              size: 56,
              color: AppStyle.errorColor,
            ),
            const SizedBox(height: AppStyle.spacingMd),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppStyle.spacingLg),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFavoritesView extends StatelessWidget {
  const _EmptyFavoritesView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppStyle.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.favorite_border_rounded,
              size: 64,
              color: AppStyle.textSecondaryColor,
            ),
            const SizedBox(height: AppStyle.spacingMd),
            Text(
              'Nenhum favorito ainda.',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppStyle.spacingSm),
            Text(
              'Toque no coracao de um produto para salvar no Supabase.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
