enum OrderStatus {
  pending('pending'),
  confirmed('confirmed'),
  preparing('preparing'),
  ready('ready'),
  delivered('delivered'),
  cancelled('cancelled');

  final String value;
  const OrderStatus(this.value);

  factory OrderStatus.fromString(String status) {
    return OrderStatus.values.firstWhere(
      (s) => s.value == status,
      orElse: () => OrderStatus.pending,
    );
  }
}
