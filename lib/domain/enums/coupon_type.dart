enum CouponType {
  percentage('percentage'),
  fixed('fixed');

  final String value;
  const CouponType(this.value);

  factory CouponType.fromString(String type) {
    return CouponType.values.firstWhere(
      (t) => t.value == type,
      orElse: () => CouponType.percentage,
    );
  }
}
