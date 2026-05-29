import 'package:ecommerce_app/controllers/orders_controller.dart';
import 'package:ecommerce_app/controllers/session_controller.dart';
import 'package:ecommerce_app/core/theme/app_style.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/models/order_status.dart';
import 'package:ecommerce_app/views/widgets/product_image_artwork.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({
    super.key,
    required this.sessionController,
    this.highlightedOrderId,
    this.successMessage,
    this.refreshSignal = 0,
  });

  final SessionController sessionController;
  final int? highlightedOrderId;
  final String? successMessage;
  final int refreshSignal;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrdersController _controller = OrdersController();

  @override
  void initState() {
    super.initState();
    _loadOrdersIfPossible();
    _showSuccessMessageIfNeeded(widget.successMessage);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant OrdersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.refreshSignal != oldWidget.refreshSignal) {
      _loadOrdersIfPossible();
    }

    if (widget.successMessage != oldWidget.successMessage &&
        widget.successMessage != null) {
      _showSuccessMessageIfNeeded(widget.successMessage);
    }
  }

  void _loadOrdersIfPossible() {
    final currentUser = widget.sessionController.currentUser;
    if (currentUser != null) {
      _controller.loadOrdersForUser(currentUser);
    }
  }

  void _showSuccessMessageIfNeeded(String? message) {
    if (message == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  Future<void> _reloadOrders() async {
    final currentUser = widget.sessionController.currentUser;
    if (currentUser == null) {
      return;
    }

    await _controller.loadOrdersForUser(currentUser);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = widget.sessionController.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus pedidos'),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (currentUser == null) {
            return const _OrdersUnavailableView();
          }

          if (_controller.isLoading && !_controller.hasOrders) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.errorMessage != null && !_controller.hasOrders) {
            return _OrdersErrorView(
              message: _controller.errorMessage!,
              onRetry: _reloadOrders,
            );
          }

          if (!_controller.hasOrders) {
            return const _OrdersEmptyView();
          }

          return RefreshIndicator(
            onRefresh: _reloadOrders,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppStyle.screenPadding,
              children: [
                _OrdersHero(
                  userName: currentUser.firstName,
                  totalOrders: _controller.orders.length,
                ),
                const SizedBox(height: AppStyle.spacingLg),
                ..._controller.orders.map(
                  (order) => Padding(
                    padding: const EdgeInsets.only(bottom: AppStyle.spacingMd),
                    child: _OrderCard(
                      order: order,
                      highlighted: order.id == widget.highlightedOrderId,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OrdersHero extends StatelessWidget {
  const _OrdersHero({
    required this.userName,
    required this.totalOrders,
  });

  final String userName;
  final int totalOrders;

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
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$totalOrders pedido(s) encontrado(s)',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppStyle.spacingLg),
          Text(
            'Tudo o que $userName ja comprou fica reunido aqui.',
            style: textTheme.displayMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppStyle.spacingSm),
          Text(
            'Acompanhe status, totais e os itens de cada pedido.',
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.highlighted,
  });

  final OrderModel order;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final highlightColor = highlighted
        ? AppStyle.accentColor.withValues(alpha: 0.18)
        : Colors.transparent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: highlighted ? AppStyle.secondaryColor.withValues(alpha: 0.45) : null,
        borderRadius: BorderRadius.circular(AppStyle.radiusLarge),
        border: Border.all(
          color: highlighted ? AppStyle.accentColor : AppStyle.borderColor,
          width: highlighted ? 1.4 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppStyle.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppStyle.radiusMedium),
                    boxShadow: highlighted ? AppStyle.softShadow : null,
                  ),
                  child: ProductImageArtwork(
                    product: order.items.first.product,
                    iconSize: 30,
                    borderRadius: BorderRadius.circular(AppStyle.radiusMedium),
                  ),
                ),
                const SizedBox(width: AppStyle.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Pedido #${order.id}',
                              style: textTheme.titleLarge,
                            ),
                          ),
                          _StatusBadge(status: order.orderStatus),
                        ],
                      ),
                      const SizedBox(height: AppStyle.spacingXs),
                      Text(
                        _formatDate(order.moment),
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppStyle.spacingSm),
                      Text(
                        _buildItemsPreview(order),
                        style: textTheme.bodyLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppStyle.spacingLg),
            Container(
              padding: const EdgeInsets.all(AppStyle.spacingMd),
              decoration: BoxDecoration(
                color: highlightColor,
                borderRadius: BorderRadius.circular(AppStyle.radiusMedium),
              ),
              child: Column(
                children: [
                  _OrderInfoRow(
                    label: 'Itens',
                    value: '${_totalItems(order)} produto(s)',
                  ),
                  const SizedBox(height: AppStyle.spacingSm),
                  _OrderInfoRow(
                    label: 'Total',
                    value: _formatPrice(order.total),
                    emphasize: true,
                  ),
                  const SizedBox(height: AppStyle.spacingSm),
                  _OrderInfoRow(
                    label: 'Pagamento',
                    value: order.payment == null
                        ? 'Aguardando confirmacao'
                        : 'Confirmado em ${_formatDate(order.payment!.moment)}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildItemsPreview(OrderModel order) {
    final names = order.items.map((item) => item.product.name).toList();
    return names.join(' | ');
  }

  int _totalItems(OrderModel order) {
    return order.items.fold(0, (total, item) => total + item.quantity);
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
    final hour = localDateTime.hour.toString().padLeft(2, '0');
    final minute = localDateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/$year as $hour:$minute';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyle.spacingSm,
        vertical: AppStyle.spacingXs,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: colors.foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  ({Color background, Color foreground}) _statusColors(OrderStatus status) {
    switch (status) {
      case OrderStatus.waitingPayment:
        return (
          background: AppStyle.warningColor.withValues(alpha: 0.18),
          foreground: const Color(0xFF9A6700),
        );
      case OrderStatus.paid:
      case OrderStatus.delivered:
        return (
          background: AppStyle.successColor.withValues(alpha: 0.16),
          foreground: AppStyle.successColor,
        );
      case OrderStatus.shipped:
        return (
          background: AppStyle.primaryColor.withValues(alpha: 0.14),
          foreground: AppStyle.primaryColor,
        );
      case OrderStatus.canceled:
        return (
          background: AppStyle.errorColor.withValues(alpha: 0.12),
          foreground: AppStyle.errorColor,
        );
    }
  }
}

class _OrderInfoRow extends StatelessWidget {
  const _OrderInfoRow({
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: emphasize ? textTheme.titleMedium : textTheme.bodyLarge,
        ),
        const SizedBox(width: AppStyle.spacingMd),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: emphasize
                ? textTheme.titleLarge?.copyWith(color: AppStyle.primaryColor)
                : textTheme.bodyMedium?.copyWith(
                    color: AppStyle.textPrimaryColor,
                  ),
          ),
        ),
      ],
    );
  }
}

class _OrdersUnavailableView extends StatelessWidget {
  const _OrdersUnavailableView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppStyle.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_person_outlined,
              size: 58,
              color: AppStyle.textSecondaryColor,
            ),
            const SizedBox(height: AppStyle.spacingMd),
            Text(
              'Entre novamente para visualizar seus pedidos.',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersErrorView extends StatelessWidget {
  const _OrdersErrorView({
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
              Icons.receipt_long_outlined,
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

class _OrdersEmptyView extends StatelessWidget {
  const _OrdersEmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppStyle.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppStyle.textSecondaryColor,
            ),
            const SizedBox(height: AppStyle.spacingMd),
            Text(
              'Voce ainda nao tem pedidos registrados.',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppStyle.spacingSm),
            Text(
              'Quando finalizar uma compra, ela vai aparecer aqui com status e total.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
