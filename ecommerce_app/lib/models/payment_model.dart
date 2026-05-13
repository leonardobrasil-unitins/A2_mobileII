class PaymentModel {
  const PaymentModel({
    required this.id,
    required this.moment,
  });

  final int id;
  final DateTime moment;

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: (map['id'] as num).toInt(),
      moment: DateTime.parse(map['moment'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'moment': moment.toUtc().toIso8601String(),
    };
  }
}
