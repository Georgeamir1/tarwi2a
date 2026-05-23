import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/enums/user_role.dart';

part 'user_profile_dto.g.dart';

@JsonSerializable()
class UserProfileDTO {
  final String id;
  @JsonKey(name: 'name')
  final String? name;
  final String? phone;
  final String? role;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  const UserProfileDTO({
    required this.id,
    this.name,
    this.phone,
    this.role,
    this.createdAt,
  });

  factory UserProfileDTO.fromJson(Map<String, dynamic> json) =>
      _$UserProfileDTOFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileDTOToJson(this);

  UserProfile toDomain() => UserProfile(
        id: id,
        name: name ?? 'مستخدم',
        phone: phone,
        role: role != null ? UserRole.fromString(role!) : UserRole.customer,
        createdAt: createdAt ?? DateTime.now(),
      );
}
