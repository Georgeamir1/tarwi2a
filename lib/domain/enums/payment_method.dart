enum PaymentMethod {
  cash('cash'),
  wallet('wallet'),
  instapay('instapay');

  final String value;
  const PaymentMethod(this.value);

  factory PaymentMethod.fromString(String method) {
    return PaymentMethod.values.firstWhere(
      (m) => m.value == method,
      orElse: () => PaymentMethod.cash,
    );
  }
}

extension PaymentMethodX on PaymentMethod {
  String get arabicLabel {
    switch (this) {
      case PaymentMethod.cash:
        return 'كاش';
      case PaymentMethod.wallet:
        return 'محفظة';
      case PaymentMethod.instapay:
        return 'انستا باي';
    }
  }
}
