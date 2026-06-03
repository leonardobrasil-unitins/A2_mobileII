import 'package:ecommerce_app/controllers/cart_controller.dart';
import 'package:ecommerce_app/controllers/favorites_controller.dart';
import 'package:ecommerce_app/controllers/profile_controller.dart';
import 'package:ecommerce_app/controllers/session_controller.dart';
import 'package:ecommerce_app/core/theme/app_style.dart';
import 'package:ecommerce_app/views/screens/cart_screen.dart';
import 'package:ecommerce_app/views/screens/orders_screen.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.sessionController,
    required this.cartController,
    required this.favoritesController,
    this.refreshSignal = 0,
    this.onOpenCart,
    this.onOpenOrders,
    this.onOpenFavorites,
  });

  final SessionController sessionController;
  final CartController cartController;
  final FavoritesController favoritesController;
  final int refreshSignal;
  final VoidCallback? onOpenCart;
  final VoidCallback? onOpenOrders;
  final VoidCallback? onOpenFavorites;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController _controller = ProfileController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.refreshSignal != oldWidget.refreshSignal) {
      _loadProfile(forceRefresh: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadProfile({bool forceRefresh = false}) async {
    final currentUser = widget.sessionController.currentUser;
    if (currentUser == null) {
      return;
    }

    await _controller.loadProfile(currentUser, forceRefresh: forceRefresh);
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

  @override
  Widget build(BuildContext context) {
    final currentUser = widget.sessionController.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu perfil'),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _controller,
          widget.cartController,
          widget.favoritesController,
        ]),
        builder: (context, _) {
          if (currentUser == null) {
            return const _ProfileUnavailableView();
          }

          return RefreshIndicator(
            onRefresh: () => _loadProfile(forceRefresh: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppStyle.screenPadding,
              children: [
                _ProfileHero(
                  name: currentUser.name,
                  email: currentUser.email,
                  phone: currentUser.phone,
                ),
                const SizedBox(height: AppStyle.spacingLg),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Pedidos',
                        value: '${_controller.totalOrders}',
                        icon: Icons.receipt_long_outlined,
                      ),
                    ),
                    const SizedBox(width: AppStyle.spacingMd),
                    Expanded(
                      child: _StatCard(
                        label: 'Aguardando',
                        value: '${_controller.waitingOrders}',
                        icon: Icons.schedule_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppStyle.spacingMd),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Favoritos',
                        value: '${widget.favoritesController.totalFavorites}',
                        icon: Icons.favorite_border_rounded,
                      ),
                    ),
                    const SizedBox(width: AppStyle.spacingMd),
                    Expanded(
                      child: _StatCard(
                        label: 'Total gasto',
                        value: _formatPrice(_controller.totalSpent),
                        icon: Icons.paid_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppStyle.spacingLg),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppStyle.spacingLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Atalhos',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppStyle.spacingMd),
                        _ProfileActionTile(
                          icon: Icons.shopping_bag_outlined,
                          title: 'Abrir carrinho',
                          subtitle:
                              'Continue de onde parou e revise seus itens.',
                          onTap: _openCart,
                        ),
                        const SizedBox(height: AppStyle.spacingSm),
                        _ProfileActionTile(
                          icon: Icons.favorite_border_rounded,
                          title: 'Ver favoritos',
                          subtitle:
                              'Produtos salvos e sincronizados no Supabase.',
                          onTap: widget.onOpenFavorites ?? () {},
                        ),
                        const SizedBox(height: AppStyle.spacingSm),
                        _ProfileActionTile(
                          icon: Icons.receipt_long_outlined,
                          title: 'Ver meus pedidos',
                          subtitle:
                              'Consulte status, pagamentos e pedidos recentes.',
                          onTap: _openOrders,
                        ),
                        const SizedBox(height: AppStyle.spacingSm),
                        _ProfileActionTile(
                          icon: Icons.logout_rounded,
                          title: 'Encerrar sessao',
                          subtitle: 'Sair da conta atual neste dispositivo.',
                          onTap: widget.sessionController.signOut,
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
                          'Resumo rapido',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppStyle.spacingMd),
                        _ProfileInfoRow(
                          label: 'Ultimo pedido',
                          value: _controller.latestOrder == null
                              ? 'Nenhum pedido ainda'
                              : '#${_controller.latestOrder!.id}',
                        ),
                        const SizedBox(height: AppStyle.spacingSm),
                        _ProfileInfoRow(
                          label: 'Ultima compra',
                          value: _controller.latestOrder == null
                              ? '-'
                              : _formatDate(_controller.latestOrder!.moment),
                        ),
                        const SizedBox(height: AppStyle.spacingSm),
                        _ProfileInfoRow(
                          label: 'Email',
                          value: currentUser.email,
                        ),
                        const SizedBox(height: AppStyle.spacingSm),
                        _ProfileInfoRow(
                          label: 'Telefone',
                          value: currentUser.phone,
                        ),
                      ],
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

  String _formatPrice(double price) {
    final fixedValue = price.toStringAsFixed(2).replaceAll('.', ',');
    return price == 0 ? 'R\$ 0,00' : 'R\$ $fixedValue';
  }

  String _formatDate(DateTime dateTime) {
    final localDateTime = dateTime.toLocal();
    final day = localDateTime.day.toString().padLeft(2, '0');
    final month = localDateTime.month.toString().padLeft(2, '0');
    final year = localDateTime.year;
    return '$day/$month/$year';
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.name,
    required this.email,
    required this.phone,
  });

  final String name;
  final String email;
  final String phone;

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
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppStyle.radiusMedium),
            ),
            alignment: Alignment.center,
            child: Text(
              name.substring(0, 1).toUpperCase(),
              style: textTheme.displayMedium?.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: AppStyle.spacingLg),
          Text(
            name,
            style: textTheme.displayMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppStyle.spacingSm),
          Text(
            email,
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppStyle.spacingXs),
          Text(
            phone,
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppStyle.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppStyle.primaryColor),
            const SizedBox(height: AppStyle.spacingMd),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppStyle.spacingXs),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppStyle.radiusMedium),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(AppStyle.spacingMd),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppStyle.radiusMedium),
          color: AppStyle.backgroundColor,
          border: Border.all(color: AppStyle.borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppStyle.secondaryColor,
                borderRadius: BorderRadius.circular(AppStyle.radiusSmall),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: AppStyle.primaryColor),
            ),
            const SizedBox(width: AppStyle.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: AppStyle.textSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: AppStyle.spacingMd),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

class _ProfileUnavailableView extends StatelessWidget {
  const _ProfileUnavailableView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppStyle.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_off_outlined,
              size: 58,
              color: AppStyle.textSecondaryColor,
            ),
            const SizedBox(height: AppStyle.spacingMd),
            Text(
              'Entre novamente para visualizar seu perfil.',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
