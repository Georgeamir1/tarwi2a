import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/user_role.dart';

part 'user_profile.freezed.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String name,
    String? phone,
    required UserRole role,
    required DateTime createdAt,
    String? fcmToken,
  }) = _UserProfile;
}
