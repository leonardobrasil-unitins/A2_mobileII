import 'package:ecommerce_app/controllers/cart_controller.dart';
import 'package:ecommerce_app/controllers/favorites_controller.dart';
import 'package:ecommerce_app/controllers/session_controller.dart';
import 'package:ecommerce_app/core/theme/app_style.dart';
import 'package:ecommerce_app/views/screens/session_gate_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const EcommerceApp());
}

class EcommerceApp extends StatefulWidget {
  const EcommerceApp({
    super.key,
    this.sessionController,
    this.cartController,
    this.favoritesController,
  });

  final SessionController? sessionController;
  final CartController? cartController;
  final FavoritesController? favoritesController;

  @override
  State<EcommerceApp> createState() => _EcommerceAppState();
}

class _EcommerceAppState extends State<EcommerceApp> {
  late final SessionController _sessionController =
      widget.sessionController ?? SessionController();
  late final CartController _cartController =
      widget.cartController ?? CartController();
  late final FavoritesController _favoritesController =
      widget.favoritesController ?? FavoritesController();

  @override
  void initState() {
    super.initState();
    _sessionController.addListener(_syncCartWithSession);
    _sessionController.addListener(_syncFavoritesWithSession);
    _syncCartWithSession();
    _syncFavoritesWithSession();
  }

  void _syncCartWithSession() {
    _cartController.attachUser(_sessionController.currentUser);
  }

  void _syncFavoritesWithSession() {
    _favoritesController.attachUser(_sessionController.currentUser);
  }

  @override
  void dispose() {
    _sessionController.removeListener(_syncCartWithSession);
    _sessionController.removeListener(_syncFavoritesWithSession);
    if (widget.sessionController == null) {
      _sessionController.dispose();
    }
    if (widget.cartController == null) {
      _cartController.dispose();
    }
    if (widget.favoritesController == null) {
      _favoritesController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce App',
      debugShowCheckedModeBanner: false,
      theme: AppStyle.theme,
      home: SessionGateScreen(
        sessionController: _sessionController,
        cartController: _cartController,
        favoritesController: _favoritesController,
      ),
    );
  }
}
