import 'package:ecommerce_app/models/checkout_payment_method.dart';

enum CheckoutDeliveryOption {
  standard,
  express;

  String get label {
    switch (this) {
      case CheckoutDeliveryOption.standard:
        return 'Entrega padrao';
      case CheckoutDeliveryOption.express:
        return 'Entrega expressa';
    }
  }

  String get subtitle {
    switch (this) {
      case CheckoutDeliveryOption.standard:
        return 'Receba entre 3 e 5 dias uteis.';
      case CheckoutDeliveryOption.express:
        return 'Receba em ate 24 horas nas regioes atendidas.';
    }
  }

  String get storageKey {
    switch (this) {
      case CheckoutDeliveryOption.standard:
        return 'standard';
      case CheckoutDeliveryOption.express:
        return 'express';
    }
  }

  static CheckoutDeliveryOption fromStorageKey(String? value) {
    return CheckoutDeliveryOption.values.firstWhere(
      (option) => option.storageKey == value,
      orElse: () => CheckoutDeliveryOption.standard,
    );
  }
}

class CheckoutDraftModel {
  const CheckoutDraftModel({
    this.zipCode = '',
    this.street = '',
    this.number = '',
    this.neighborhood = '',
    this.city = '',
    this.state = '',
    this.complement = '',
    this.deliveryInstructions = '',
    this.deliveryOption = CheckoutDeliveryOption.standard,
    this.paymentMethod = CheckoutPaymentMethod.pix,
  });

  final String zipCode;
  final String street;
  final String number;
  final String neighborhood;
  final String city;
  final String state;
  final String complement;
  final String deliveryInstructions;
  final CheckoutDeliveryOption deliveryOption;
  final CheckoutPaymentMethod paymentMethod;

  String get formattedAddress {
    final lineOne = [street.trim(), if (number.trim().isNotEmpty) number.trim()]
        .join(', ');
    final lineTwo = [
      neighborhood.trim(),
      city.trim(),
      state.trim(),
      if (zipCode.trim().isNotEmpty) 'CEP $zipCode',
    ].where((value) => value.isNotEmpty).join(' - ');

    if (lineOne.isEmpty && lineTwo.isEmpty) {
      return 'Endereco ainda nao preenchido.';
    }

    if (lineOne.isEmpty) {
      return lineTwo;
    }

    if (lineTwo.isEmpty) {
      return lineOne;
    }

    return '$lineOne\n$lineTwo';
  }

  CheckoutDraftModel copyWith({
    String? zipCode,
    String? street,
    String? number,
    String? neighborhood,
    String? city,
    String? state,
    String? complement,
    String? deliveryInstructions,
    CheckoutDeliveryOption? deliveryOption,
    CheckoutPaymentMethod? paymentMethod,
  }) {
    return CheckoutDraftModel(
      zipCode: zipCode ?? this.zipCode,
      street: street ?? this.street,
      number: number ?? this.number,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      state: state ?? this.state,
      complement: complement ?? this.complement,
      deliveryInstructions:
          deliveryInstructions ?? this.deliveryInstructions,
      deliveryOption: deliveryOption ?? this.deliveryOption,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'zipCode': zipCode,
      'street': street,
      'number': number,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'complement': complement,
      'deliveryInstructions': deliveryInstructions,
      'deliveryOption': deliveryOption.storageKey,
      'paymentMethod': paymentMethod.storageKey,
    };
  }

  factory CheckoutDraftModel.fromMap(Map<String, dynamic> map) {
    return CheckoutDraftModel(
      zipCode: map['zipCode'] as String? ?? '',
      street: map['street'] as String? ?? '',
      number: map['number'] as String? ?? '',
      neighborhood: map['neighborhood'] as String? ?? '',
      city: map['city'] as String? ?? '',
      state: map['state'] as String? ?? '',
      complement: map['complement'] as String? ?? '',
      deliveryInstructions: map['deliveryInstructions'] as String? ?? '',
      deliveryOption: CheckoutDeliveryOption.fromStorageKey(
        map['deliveryOption'] as String?,
      ),
      paymentMethod: CheckoutPaymentMethod.fromStorageKey(
        map['paymentMethod'] as String?,
      ),
    );
  }
}
