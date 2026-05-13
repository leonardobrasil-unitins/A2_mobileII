import 'package:ecommerce_app/controllers/cart_controller.dart';
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
  });

  final SessionController? sessionController;
  final CartController? cartController;

  @override
  State<EcommerceApp> createState() => _EcommerceAppState();
}

class _EcommerceAppState extends State<EcommerceApp> {
  late final SessionController _sessionController =
      widget.sessionController ?? SessionController();
  late final CartController _cartController =
      widget.cartController ?? CartController();

  @override
  void initState() {
    super.initState();
    _sessionController.addListener(_syncCartWithSession);
    _syncCartWithSession();
  }

  void _syncCartWithSession() {
    _cartController.attachUser(_sessionController.currentUser);
  }

  @override
  void dispose() {
    _sessionController.removeListener(_syncCartWithSession);
    if (widget.sessionController == null) {
      _sessionController.dispose();
    }
    if (widget.cartController == null) {
      _cartController.dispose();
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
      ),
    );
  }
}
