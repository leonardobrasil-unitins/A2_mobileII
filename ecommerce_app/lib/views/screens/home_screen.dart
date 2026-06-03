import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecommerce_app/controllers/cart_controller.dart';
import 'package:ecommerce_app/controllers/favorites_controller.dart';
import 'package:ecommerce_app/controllers/home_controller.dart';
import 'package:ecommerce_app/controllers/session_controller.dart';
import 'package:ecommerce_app/core/theme/app_style.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/views/screens/cart_screen.dart';
import 'package:ecommerce_app/views/screens/orders_screen.dart';
import 'package:ecommerce_app/views/screens/product_details_screen.dart';
import 'package:ecommerce_app/views/widgets/product_carousel_card.dart';
import 'package:ecommerce_app/views/widgets/product_image_artwork.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.sessionController,
    required this.cartController,
    this.favoritesController,
    this.onOpenCart,
    this.onOpenOrders,
    this.onOpenProfile,
  });

  final SessionController sessionController;
  final CartController cartController;
  final FavoritesController? favoritesController;
  final VoidCallback? onOpenCart;
  final VoidCallback? onOpenOrders;
  final VoidCallback? onOpenProfile;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController _controller = HomeController();
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _preloadedImageUrls = <String>{};

  void _openProductDetails(ProductModel product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailsScreen(
          product: product,
          cartController: widget.cartController,
          sessionController: widget.sessionController,
          favoritesController: widget.favoritesController,
        ),
      ),
    );
  }

  void _openCart() {
    if (widget.onOpenCart != null) {
      widget.onOpenCart!();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CartScreen(
          cartController: widget.cartController,
          sessionController: widget.sessionController,
        ),
      ),
    );
  }

  void _openOrders() {
    if (widget.onOpenOrders != null) {
      widget.onOpenOrders!();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OrdersScreen(
          sessionController: widget.sessionController,
        ),
      ),
    );
  }

  Future<void> _addToCart(ProductModel product) async {
    await widget.cartController.addProduct(product);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} foi adicionado ao carrinho.'),
      ),
    );
  }

  Future<void> _toggleFavorite(ProductModel product) async {
    final favoritesController = widget.favoritesController;

    if (favoritesController == null) {
      return;
    }

    await favoritesController.toggleFavorite(
      user: widget.sessionController.currentUser,
      product: product,
    );

    if (!mounted || favoritesController.errorMessage == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(favoritesController.errorMessage!)),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleControllerChange);
    _controller.loadHomeData();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChange);
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleControllerChange() {
    if (!mounted || _controller.featuredProducts.isEmpty) {
      return;
    }

    unawaited(_precacheProductImages(_controller.featuredProducts));
  }

  Future<void> _precacheProductImages(List<ProductModel> products) async {
    final pendingUrls = <String>[];

    for (final product in products) {
      final imageUrl = product.imgUrl.trim();

      if (imageUrl.isEmpty || !_preloadedImageUrls.add(imageUrl)) {
        continue;
      }

      pendingUrls.add(imageUrl);
    }

    for (final imageUrl in pendingUrls) {
      try {
        await precacheImage(NetworkImage(imageUrl), context);
      } catch (_) {
        _preloadedImageUrls.remove(imageUrl);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = widget.sessionController.currentUser;
    final userName = currentUser?.firstName ?? 'visitante';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pulse Shop'),
        actions: [
          if (widget.onOpenProfile != null)
            IconButton(
              tooltip: 'Perfil',
              onPressed: widget.onOpenProfile,
              icon: const Icon(Icons.person_outline_rounded),
            )
          else
            IconButton(
              tooltip: 'Meus pedidos',
              onPressed: _openOrders,
              icon: const Icon(Icons.receipt_long_outlined),
            ),
          IconButton(
            tooltip: 'Sair',
            onPressed: widget.sessionController.signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
          if (widget.onOpenProfile == null)
            Padding(
              padding: const EdgeInsets.only(right: AppStyle.spacingMd),
              child: AnimatedBuilder(
                animation: widget.cartController,
                builder: (context, _) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        tooltip: 'Carrinho',
                        onPressed: _openCart,
                        icon: const Icon(Icons.shopping_bag_outlined),
                      ),
                      if (widget.cartController.totalItems > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppStyle.accentColor,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${widget.cartController.totalItems}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.favoritesController == null
            ? _controller
            : Listenable.merge([
                _controller,
                widget.favoritesController!,
              ]),
        builder: (context, _) {
          if (_controller.isLoading && _controller.featuredProducts.isEmpty) {
            return const _HomeLoadingView();
          }

          if (_controller.errorMessage != null &&
              _controller.featuredProducts.isEmpty) {
            return _HomeErrorView(
              message: _controller.errorMessage!,
              onRetry: _controller.loadHomeData,
            );
          }

          return RefreshIndicator(
            onRefresh: _controller.loadHomeData,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppStyle.screenPadding,
              children: [
                _HeroBanner(userName: userName),
                const SizedBox(height: AppStyle.spacingLg),
                Text(
                  'Busque por nome ou categoria',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppStyle.spacingMd),
                TextField(
                  controller: _searchController,
                  onChanged: _controller.updateSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Ex.: books, computers, smart tv...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _controller.searchQuery.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _controller.updateSearchQuery('');
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
                const SizedBox(height: AppStyle.spacingLg),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Destaques do momento',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    if (_controller.isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: AppStyle.spacingMd),
                if (_controller.visibleProducts.isEmpty)
                  const _EmptyProductsView()
                else ...[
                  CarouselSlider.builder(
                    itemCount: _controller.visibleProducts.length,
                    itemBuilder: (context, index, realIndex) {
                      final product = _controller.visibleProducts[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppStyle.spacingXs,
                        ),
                        child: GestureDetector(
                          onTap: () => _openProductDetails(product),
                          child: ProductCarouselCard(
                            product: product,
                            isFavorite: widget.favoritesController
                                    ?.isFavorite(product.id) ??
                                false,
                            onToggleFavorite:
                                widget.favoritesController == null
                                    ? null
                                    : () => _toggleFavorite(product),
                          ),
                        ),
                      );
                    },
                    options: CarouselOptions(
                      height: 360,
                      viewportFraction: 0.86,
                      enlargeCenterPage: true,
                      enlargeFactor: 0.18,
                      autoPlay: _controller.visibleProducts.length > 1,
                      autoPlayInterval: const Duration(seconds: 4),
                    ),
                  ),
                  const SizedBox(height: AppStyle.spacingLg),
                  Text(
                    'Resultados',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppStyle.spacingMd),
                  ..._controller.visibleProducts.map(
                    (product) => Padding(
                      padding: const EdgeInsets.only(bottom: AppStyle.spacingMd),
                      child: _ProductResultCard(
                        product: product,
                        onTap: () => _openProductDetails(product),
                        onAddToCart: () => _addToCart(product),
                        isFavorite:
                            widget.favoritesController?.isFavorite(product.id) ??
                                false,
                        onToggleFavorite: widget.favoritesController == null
                            ? null
                            : () => _toggleFavorite(product),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.userName});

  final String userName;

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
              'Sessao ativa para $userName',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppStyle.spacingLg),
          Text(
            'Seu shopping de bolso com vitrine dinamica.',
            style: textTheme.displayMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppStyle.spacingSm),
          Text(
            'Pesquise por nome ou categoria, explore o carousel e monte seu carrinho local.',
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductResultCard extends StatelessWidget {
  const _ProductResultCard({
    required this.product,
    required this.onTap,
    required this.onAddToCart,
    required this.isFavorite,
    this.onToggleFavorite,
  });

  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                    Wrap(
                      spacing: AppStyle.spacingXs,
                      runSpacing: AppStyle.spacingXs,
                      children: product.categories
                          .map((category) => Chip(label: Text(category.name)))
                          .toList(),
                    ),
                    const SizedBox(height: AppStyle.spacingSm),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(product.name, style: textTheme.titleLarge),
                        ),
                        if (onToggleFavorite != null)
                          IconButton(
                            tooltip: isFavorite
                                ? 'Remover dos favoritos'
                                : 'Salvar nos favoritos',
                            onPressed: onToggleFavorite,
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isFavorite ? AppStyle.accentColor : null,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppStyle.spacingXs),
                    Text(
                      product.description,
                      style: textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppStyle.spacingMd),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatPrice(product.price),
                            style: textTheme.titleLarge?.copyWith(
                              color: AppStyle.primaryColor,
                            ),
                          ),
                        ),
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
}

class _HomeLoadingView extends StatelessWidget {
  const _HomeLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _HomeErrorView extends StatelessWidget {
  const _HomeErrorView({
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
              Icons.wifi_off_rounded,
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

class _EmptyProductsView extends StatelessWidget {
  const _EmptyProductsView();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppStyle.screenPadding,
        child: Column(
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 44,
              color: AppStyle.textSecondaryColor,
            ),
            const SizedBox(height: AppStyle.spacingSm),
            Text(
              'Nenhum produto encontrado com esse filtro.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
