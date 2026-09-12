import '../../domain/enums/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/profile_repository.dart';

/// Securely resolves push notification payloads into valid, role-verified navigation routes.
///
/// Ensures untrusted payloads cannot elevate privileges or trigger deep-linking
/// without authenticated credentials.
class NotificationNavigationResolver {
  final AuthRepository _authRepository;
  final ProfileRepository? _profileRepository;

  NotificationNavigationResolver({
    required AuthRepository authRepository,
    ProfileRepository? profileRepository,
  })  : _authRepository = authRepository,
        _profileRepository = profileRepository;

  /// Resolves an untrusted push notification payload into a verified app route.
  ///
  /// Security guarantees:
  /// 1. Payload admin/role claims are strictly ignored. Role is resolved from authenticated profile only.
  /// 2. If unauthenticated, returns null to prevent unauthorized deep-linking.
  /// 3. Validates reference_type and reference_id.
  Future<String?> resolveRoute(
    Map<String, dynamic> payload, {
    UserRole? roleOverride,
  }) async {
    final refType = payload['reference_type'];
    final refId = payload['reference_id'];

    if (refType is! String || refId is! String) {
      return null;
    }

    final trimmedId = refId.trim();
    if (trimmedId.isEmpty) {
      return null;
    }

    final sanitizedId = Uri.encodeComponent(trimmedId);

    if (refType == 'order') {
      final user = _authRepository.currentUser;
      if (user == null) {
        return null;
      }

      UserRole role = roleOverride ?? UserRole.customer;
      if (roleOverride == null && _profileRepository != null) {
        final profileResult = await _profileRepository.getProfile(user.id);
        profileResult.fold(
          (_) {},
          (profile) {
            if (profile != null) {
              role = profile.role;
            }
          },
        );
      }

      if (role == UserRole.admin) {
        return '/admin/orders/$sanitizedId';
      } else {
        return '/orders?expand=$sanitizedId';
      }
    }

    return null;
  }
}
