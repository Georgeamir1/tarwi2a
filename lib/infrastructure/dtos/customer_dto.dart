import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/enums/user_role.dart';

part 'customer_dto.g.dart';

@JsonSerializable()
class CustomerDTO {
  final String id;
  final String name;
  final String? phone;
  final String? role;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'total_orders')
  final int? totalOrders;
  @JsonKey(name: 'total_spent')
  final double? totalSpent;
  @JsonKey(name: 'last_order_at')
  final DateTime? lastOrderAt;

  const CustomerDTO({
    required this.id,
    required this.name,
    this.phone,
    this.role,
    this.createdAt,
    this.totalOrders,
    this.totalSpent,
    this.lastOrderAt,
  });

  factory CustomerDTO.fromJson(Map<String, dynamic> json) =>
      _$CustomerDTOFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerDTOToJson(this);

  Customer toDomain() => Customer(
        id: id,
        name: name,
        phone: phone,
        role: role != null ? UserRole.fromString(role!) : UserRole.customer,
        totalOrders: totalOrders ?? 0,
        totalSpent: totalSpent ?? 0,
        lastOrderAt: lastOrderAt,
        createdAt: createdAt ?? DateTime.now(),
      );
}
