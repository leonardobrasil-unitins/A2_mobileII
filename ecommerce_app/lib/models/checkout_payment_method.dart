import 'package:flutter/material.dart';

enum CheckoutPaymentMethod {
  pix,
  cardOnDelivery,
  boleto;

  String get label {
    switch (this) {
      case CheckoutPaymentMethod.pix:
        return 'Pix';
      case CheckoutPaymentMethod.cardOnDelivery:
        return 'Cartao na entrega';
      case CheckoutPaymentMethod.boleto:
        return 'Boleto';
    }
  }

  String get subtitle {
    switch (this) {
      case CheckoutPaymentMethod.pix:
        return 'Confirmacao rapida para agilizar o pedido.';
      case CheckoutPaymentMethod.cardOnDelivery:
        return 'Pague com cartao quando receber o produto.';
      case CheckoutPaymentMethod.boleto:
        return 'Geracao de boleto para pagamento posterior.';
    }
  }

  IconData get icon {
    switch (this) {
      case CheckoutPaymentMethod.pix:
        return Icons.qr_code_2_rounded;
      case CheckoutPaymentMethod.cardOnDelivery:
        return Icons.credit_card_rounded;
      case CheckoutPaymentMethod.boleto:
        return Icons.receipt_long_outlined;
    }
  }

  String get storageKey {
    switch (this) {
      case CheckoutPaymentMethod.pix:
        return 'pix';
      case CheckoutPaymentMethod.cardOnDelivery:
        return 'card_on_delivery';
      case CheckoutPaymentMethod.boleto:
        return 'boleto';
    }
  }

  static CheckoutPaymentMethod fromStorageKey(String? value) {
    return CheckoutPaymentMethod.values.firstWhere(
      (method) => method.storageKey == value,
      orElse: () => CheckoutPaymentMethod.pix,
    );
  }
}
