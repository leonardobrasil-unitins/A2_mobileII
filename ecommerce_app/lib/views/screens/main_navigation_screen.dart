import 'package:ecommerce_app/controllers/cart_controller.dart';
import 'package:ecommerce_app/controllers/favorites_controller.dart';
import 'package:ecommerce_app/controllers/main_navigation_controller.dart';
import 'package:ecommerce_app/controllers/session_controller.dart';
import 'package:ecommerce_app/core/theme/app_style.dart';
import 'package:ecommerce_app/models/order_model.dart';
import 'package:ecommerce_app/views/screens/cart_screen.dart';
import 'package:ecommerce_app/views/screens/favorites_screen.dart';
import 'package:ecommerce_app/views/screens/home_screen.dart';
import 'package:ecommerce_app/views/screens/orders_screen.dart';
import 'package:ecommerce_app/views/screens/profile_screen.dart';
import 'package:flutter/material.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({
    super.key,
    required this.sessionController,
    required this.cartController,
    required this.favoritesController,
    this.navigationController,
  });

  final SessionController sessionController;
  final CartController cartController;
  final FavoritesController favoritesController;
  final MainNavigationController? navigationController;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late final MainNavigationController _navigationController =
      widget.navigationController ?? MainNavigationController();

  final Set<MainTab> _visitedTabs = <MainTab>{MainTab.home};
  int _ordersRefreshSignal = 0;
  int _profileRefreshSignal = 0;
  int? _highlightedOrderId;
  String? _ordersSuccessMessage;

  @override
  void dispose() {
    if (widget.navigationController == null) {
      _navigationController.dispose();
    }
    super.dispose();
  }

  void _selectTab(MainTab tab) {
    setState(() {
      _visitedTabs.add(tab);

      if (tab == MainTab.orders) {
        _ordersRefreshSignal++;
      }

      if (tab == MainTab.profile) {
        _profileRefreshSignal++;
      }
    });

    _navigationController.selectTab(tab);
  }

  Future<void> _handleCheckoutCompleted(OrderModel order) async {
    setState(() {
      _visitedTabs.add(MainTab.orders);
      _highlightedOrderId = order.id;
      _ordersSuccessMessage = 'Pedido #${order.id} criado com sucesso.';
      _ordersRefreshSignal++;
      _profileRefreshSignal++;
    });

    _navigationController.selectTab(MainTab.orders);
  }

  Widget _buildTab(MainTab tab) {
    if (!_visitedTabs.contains(tab)) {
      return const SizedBox.expand();
    }

    switch (tab) {
      case MainTab.home:
        return HomeScreen(
          sessionController: widget.sessionController,
          cartController: widget.cartController,
          favoritesController: widget.favoritesController,
          onOpenCart: () => _selectTab(MainTab.cart),
          onOpenOrders: () => _selectTab(MainTab.orders),
          onOpenProfile: () => _selectTab(MainTab.profile),
        );
      case MainTab.cart:
        return CartScreen(
          cartController: widget.cartController,
          sessionController: widget.sessionController,
          onOpenOrders: () => _selectTab(MainTab.orders),
          onCheckoutCompleted: _handleCheckoutCompleted,
        );
      case MainTab.favorites:
        return FavoritesScreen(
          sessionController: widget.sessionController,
          cartController: widget.cartController,
          favoritesController: widget.favoritesController,
        );
      case MainTab.orders:
        return OrdersScreen(
          sessionController: widget.sessionController,
          highlightedOrderId: _highlightedOrderId,
          successMessage: _ordersSuccessMessage,
          refreshSignal: _ordersRefreshSignal,
        );
      case MainTab.profile:
        return ProfileScreen(
          sessionController: widget.sessionController,
          cartController: widget.cartController,
          favoritesController: widget.favoritesController,
          refreshSignal: _profileRefreshSignal,
          onOpenCart: () => _selectTab(MainTab.cart),
          onOpenOrders: () => _selectTab(MainTab.orders),
          onOpenFavorites: () => _selectTab(MainTab.favorites),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _navigationController,
        widget.cartController,
        widget.favoritesController,
      ]),
      builder: (context, _) {
        return Scaffold(
          body: IndexedStack(
            index: _navigationController.currentIndex,
            children: MainTab.values.map(_buildTab).toList(),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _navigationController.currentIndex,
            onDestinationSelected: (index) => _selectTab(MainTab.values[index]),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: _NavigationIconBadge(
                  icon: Icons.shopping_bag_outlined,
                  selectedIcon: Icons.shopping_bag_rounded,
                  count: widget.cartController.totalItems,
                  selected: _navigationController.currentTab == MainTab.cart,
                ),
                selectedIcon: _NavigationIconBadge(
                  icon: Icons.shopping_bag_outlined,
                  selectedIcon: Icons.shopping_bag_rounded,
                  count: widget.cartController.totalItems,
                  selected: true,
                ),
                label: 'Carrinho',
              ),
              NavigationDestination(
                icon: _NavigationIconBadge(
                  icon: Icons.favorite_border_rounded,
                  selectedIcon: Icons.favorite_rounded,
                  count: widget.favoritesController.totalFavorites,
                  selected:
                      _navigationController.currentTab == MainTab.favorites,
                ),
                selectedIcon: _NavigationIconBadge(
                  icon: Icons.favorite_border_rounded,
                  selectedIcon: Icons.favorite_rounded,
                  count: widget.favoritesController.totalFavorites,
                  selected: true,
                ),
                label: 'Favoritos',
              ),
              const NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long_rounded),
                label: 'Pedidos',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Perfil',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavigationIconBadge extends StatelessWidget {
  const _NavigationIconBadge({
    required this.icon,
    required this.selectedIcon,
    required this.count,
    required this.selected,
  });

  final IconData icon;
  final IconData selectedIcon;
  final int count;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(selected ? selectedIcon : icon),
        if (count > 0)
          Positioned(
            top: -6,
            right: -10,
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
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
