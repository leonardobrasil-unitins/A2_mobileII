import 'package:ecommerce_app/controllers/cart_controller.dart';
import 'package:ecommerce_app/controllers/session_controller.dart';
import 'package:ecommerce_app/core/theme/app_style.dart';
import 'package:ecommerce_app/models/order_item_model.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/views/screens/checkout_screen.dart';
import 'package:ecommerce_app/views/screens/orders_screen.dart';
import 'package:ecommerce_app/views/widgets/product_image_artwork.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({
    super.key,
    required this.cartController,
    required this.sessionController,
    this.onOpenOrders,
    this.onCheckoutCompleted,
  });

  final CartController cartController;
  final SessionController sessionController;
  final VoidCallback? onOpenOrders;
  final Future<void> Function(OrderModel order)? onCheckoutCompleted;

  Future<void> _openCheckout(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CheckoutScreen(
          cartController: cartController,
          sessionController: sessionController,
          onCheckoutCompleted: onCheckoutCompleted,
        ),
      ),
    );
  }

  void _openOrders(BuildContext context) {
    if (onOpenOrders != null) {
      onOpenOrders!();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OrdersScreen(sessionController: sessionController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu carrinho'),
        actions: [
          IconButton(
            tooltip: 'Meus pedidos',
            onPressed: () => _openOrders(context),
            icon: const Icon(Icons.receipt_long_outlined),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: cartController,
        builder: (context, _) {
          if (cartController.isLoading && !cartController.hasItems) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!cartController.hasItems) {
            return const _EmptyCartView();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: AppStyle.screenPadding,
                  itemBuilder: (context, index) {
                    final item = cartController.items[index];
                    return _CartItemCard(
                      item: item,
                      isBusy: cartController.isLoading,
                      onIncrease: () => cartController.increaseQuantity(item),
                      onDecrease: () => cartController.decreaseQuantity(item),
                      onRemove: () => cartController.removeItem(item),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppStyle.spacingMd),
                  itemCount: cartController.items.length,
                ),
              ),
              SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(
                  AppStyle.spacingLg,
                  AppStyle.spacingSm,
                  AppStyle.spacingLg,
                  AppStyle.spacingLg,
                ),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppStyle.spacingLg),
                    child: Column(
                      children: [
                        _SummaryRow(
                          label: 'Itens',
                          value: '${cartController.totalItems}',
                        ),
                        const SizedBox(height: AppStyle.spacingSm),
                        _SummaryRow(
                          label: 'Total',
                          value: _formatPrice(cartController.totalAmount),
                          emphasize: true,
                        ),
                        if (cartController.errorMessage != null) ...[
                          const SizedBox(height: AppStyle.spacingMd),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppStyle.spacingMd),
                            decoration: BoxDecoration(
                              color: AppStyle.errorColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(
                                AppStyle.radiusMedium,
                              ),
                              border: Border.all(
                                color: AppStyle.errorColor.withValues(
                                  alpha: 0.18,
                                ),
                              ),
                            ),
                            child: Text(
                              cartController.errorMessage!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppStyle.errorColor,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: AppStyle.spacingLg),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: cartController.isLoading
                                ? null
                                : () => _openCheckout(context),
                            child: const Text('Ir para checkout'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatPrice(double price) {
    final fixedValue = price.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $fixedValue';
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.isBusy,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  final OrderItemModel item;
  final bool isBusy;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppStyle.spacingMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 92,
              height: 92,
              child: ProductImageArtwork(
                product: item.product,
                iconSize: 36,
                borderRadius: BorderRadius.circular(AppStyle.radiusMedium),
              ),
            ),
            const SizedBox(width: AppStyle.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.name, style: textTheme.titleMedium),
                  const SizedBox(height: AppStyle.spacingXs),
                  Text(
                    item.product.categories
                        .map((category) => category.name)
                        .join(', '),
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppStyle.spacingSm),
                  Text(
                    _formatPrice(item.subTotal),
                    style: textTheme.titleLarge?.copyWith(
                      color: AppStyle.primaryColor,
                    ),
                  ),
                  const SizedBox(height: AppStyle.spacingSm),
                  Row(
                    children: [
                      _QuantityButton(
                        icon: Icons.remove_rounded,
                        onPressed: isBusy ? null : onDecrease,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppStyle.spacingMd,
                        ),
                        child: Text(
                          '${item.quantity}',
                          style: textTheme.titleMedium,
                        ),
                      ),
                      _QuantityButton(
                        icon: Icons.add_rounded,
                        onPressed: isBusy ? null : onIncrease,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: isBusy ? null : onRemove,
                        child: const Text('Remover'),
                      ),
                    ],
                  ),
                ],
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

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: AppStyle.secondaryColor,
        borderRadius: BorderRadius.circular(AppStyle.radiusSmall),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: AppStyle.primaryColor,
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Text(
          label,
          style: emphasize ? textTheme.titleMedium : textTheme.bodyLarge,
        ),
        const Spacer(),
        Text(
          value,
          style: emphasize
              ? textTheme.titleLarge?.copyWith(color: AppStyle.primaryColor)
              : textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppStyle.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: AppStyle.textSecondaryColor,
            ),
            const SizedBox(height: AppStyle.spacingMd),
            Text(
              'Seu carrinho ainda esta vazio.',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppStyle.spacingSm),
            Text(
              'Adicione produtos na home ou na tela de detalhes para comecar.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
