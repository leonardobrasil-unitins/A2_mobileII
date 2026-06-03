import 'package:ecommerce_app/controllers/cart_controller.dart';
import 'package:ecommerce_app/controllers/favorites_controller.dart';
import 'package:ecommerce_app/controllers/session_controller.dart';
import 'package:ecommerce_app/views/screens/login_screen.dart';
import 'package:ecommerce_app/views/screens/main_navigation_screen.dart';
import 'package:flutter/material.dart';

class SessionGateScreen extends StatefulWidget {
  const SessionGateScreen({
    super.key,
    required this.sessionController,
    required this.cartController,
    required this.favoritesController,
  });

  final SessionController sessionController;
  final CartController cartController;
  final FavoritesController favoritesController;

  @override
  State<SessionGateScreen> createState() => _SessionGateScreenState();
}

class _SessionGateScreenState extends State<SessionGateScreen> {
  @override
  void initState() {
    super.initState();
    widget.sessionController.restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.sessionController,
      builder: (context, _) {
        if (!widget.sessionController.isInitialized ||
            (widget.sessionController.isLoading &&
                !widget.sessionController.isAuthenticated)) {
          return const _SessionLoadingScreen();
        }

        if (widget.sessionController.isAuthenticated) {
          return MainNavigationScreen(
            sessionController: widget.sessionController,
            cartController: widget.cartController,
            favoritesController: widget.favoritesController,
          );
        }

        return LoginScreen(sessionController: widget.sessionController);
      },
    );
  }
}

class _SessionLoadingScreen extends StatelessWidget {
  const _SessionLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
