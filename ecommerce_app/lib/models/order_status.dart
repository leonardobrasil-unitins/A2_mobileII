enum OrderStatus {
  waitingPayment('WAITING_PAYMENT'),
  paid('PAID'),
  shipped('SHIPPED'),
  delivered('DELIVERED'),
  canceled('CANCELED');

  const OrderStatus(this.apiValue);

  final String apiValue;

  static OrderStatus fromApiValue(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.apiValue == value,
      orElse: () => OrderStatus.waitingPayment,
    );
  }
}

extension OrderStatusLabel on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.waitingPayment:
        return 'Aguardando pagamento';
      case OrderStatus.paid:
        return 'Pago';
      case OrderStatus.shipped:
        return 'Enviado';
      case OrderStatus.delivered:
        return 'Entregue';
      case OrderStatus.canceled:
        return 'Cancelado';
    }
  }
}
