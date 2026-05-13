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
