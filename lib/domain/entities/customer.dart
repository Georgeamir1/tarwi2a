import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/user_role.dart';

part 'customer.freezed.dart';

@freezed
class Customer with _$Customer {
  const factory Customer({
    required String id,
    required String name,
    String? phone,
    required UserRole role,
    required int totalOrders,
    required double totalSpent,
    DateTime? lastOrderAt,
    required DateTime createdAt,
  }) = _Customer;
}
