import 'package:ecommerce_app/controllers/cart_controller.dart';
import 'package:ecommerce_app/controllers/product_details_controller.dart';
import 'package:ecommerce_app/controllers/session_controller.dart';
import 'package:ecommerce_app/core/theme/app_style.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/views/screens/cart_screen.dart';
import 'package:ecommerce_app/views/widgets/product_image_artwork.dart';
import 'package:flutter/material.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({
    super.key,
    required this.product,
    required this.cartController,
    required this.sessionController,
  });

  final ProductModel product;
  final CartController cartController;
  final SessionController sessionController;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late final ProductDetailsController _controller =
      ProductDetailsController(initialProduct: widget.product);

  @override
  void initState() {
    super.initState();
    _controller.loadProductDetails();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addToCart({bool openCartAfterAdd = false}) async {
    final product = _controller.product;
    await widget.cartController.addProduct(product);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} foi adicionado ao carrinho.')),
    );

    if (openCartAfterAdd) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CartScreen(
            cartController: widget.cartController,
            sessionController: widget.sessionController,
          ),
        ),
      );
    }
  }

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CartScreen(
          cartController: widget.cartController,
          sessionController: widget.sessionController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _controller,
          widget.cartController,
        ]),
        builder: (context, _) {
          final product = _controller.product;
          final textTheme = Theme.of(context).textTheme;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 360,
                pinned: true,
                stretch: true,
                backgroundColor: AppStyle.backgroundColor,
                foregroundColor: AppStyle.textPrimaryColor,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: AppStyle.spacingMd),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
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
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      ProductImageArtwork(product: product, iconSize: 92),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x100F172A),
                              Color(0x250F172A),
                              Color(0xD90F172A),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppStyle.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: AppStyle.spacingSm,
                        runSpacing: AppStyle.spacingSm,
                        children: product.categories
                            .map((category) => Chip(label: Text(category.name)))
                            .toList(),
                      ),
                      const SizedBox(height: AppStyle.spacingMd),
                      Text(
                        product.name,
                        style: textTheme.displayMedium,
                      ),
                      const SizedBox(height: AppStyle.spacingSm),
                      Text(
                        _formatPrice(product.price),
                        style: textTheme.displayLarge?.copyWith(
                          fontSize: 38,
                          color: AppStyle.primaryColor,
                        ),
                      ),
                      const SizedBox(height: AppStyle.spacingLg),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppStyle.spacingLg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.auto_awesome_rounded,
                                    color: AppStyle.accentColor,
                                  ),
                                  const SizedBox(width: AppStyle.spacingSm),
                                  Text(
                                    'Sobre o produto',
                                    style: textTheme.titleLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppStyle.spacingMd),
                              Text(
                                product.description,
                                style: textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppStyle.spacingLg),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppStyle.spacingLg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Destaques',
                                style: textTheme.titleLarge,
                              ),
                              const SizedBox(height: AppStyle.spacingMd),
                              const _FeatureRow(
                                icon: Icons.local_shipping_outlined,
                                title: 'Entrega',
                                subtitle:
                                    'Previsao rapida para produtos em destaque.',
                              ),
                              const SizedBox(height: AppStyle.spacingMd),
                              const _FeatureRow(
                                icon: Icons.verified_outlined,
                                title: 'Compra segura',
                                subtitle:
                                    'Fluxo pronto para evoluir com checkout e pedidos.',
                              ),
                              const SizedBox(height: AppStyle.spacingMd),
                              _FeatureRow(
                                icon: Icons.category_outlined,
                                title: 'Categoria',
                                subtitle: product.categories
                                    .map((category) => category.name)
                                    .join(', '),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_controller.errorMessage != null) ...[
                        const SizedBox(height: AppStyle.spacingLg),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppStyle.spacingMd),
                          decoration: BoxDecoration(
                            color: AppStyle.errorColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(
                              AppStyle.radiusMedium,
                            ),
                            border: Border.all(
                              color: AppStyle.errorColor.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Text(
                            _controller.errorMessage!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppStyle.errorColor,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppStyle.spacingLg,
          AppStyle.spacingSm,
          AppStyle.spacingLg,
          AppStyle.spacingLg,
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _addToCart,
                child: const Text('Adicionar'),
              ),
            ),
            const SizedBox(width: AppStyle.spacingSm),
            Expanded(
              child: FilledButton(
                onPressed: () => _addToCart(openCartAfterAdd: true),
                child: const Text('Comprar agora'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    final fixedValue = price.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $fixedValue';
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppStyle.secondaryColor,
            borderRadius: BorderRadius.circular(AppStyle.radiusSmall),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: AppStyle.primaryColor,
          ),
        ),
        const SizedBox(width: AppStyle.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(subtitle, style: textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
