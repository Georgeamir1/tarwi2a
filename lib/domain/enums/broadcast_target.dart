enum BroadcastTargetType {
  all('all'),
  customers('customers'),
  admins('admins'),
  specific('specific');

  final String value;
  const BroadcastTargetType(this.value);

  factory BroadcastTargetType.fromValue(String value) {
    return BroadcastTargetType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => BroadcastTargetType.all,
    );
  }

  String get arabicLabel {
    switch (this) {
      case BroadcastTargetType.all:
        return 'كل المستخدمين';
      case BroadcastTargetType.customers:
        return 'العملاء فقط';
      case BroadcastTargetType.admins:
        return 'الإدارة فقط';
      case BroadcastTargetType.specific:
        return 'مستخدمين محددين';
    }
  }
}
