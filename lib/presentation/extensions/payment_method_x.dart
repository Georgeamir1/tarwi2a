import '../../../domain/enums/payment_method.dart';

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
