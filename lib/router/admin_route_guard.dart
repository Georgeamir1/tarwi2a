import '../domain/enums/user_role.dart';

/// Guard to prevent unauthorized access to administrative routes.
///
/// An admin route is defined as either exactly `'/admin'` or starting with `'/admin/'`.
/// Paths such as `'/administrator'` are NOT considered admin routes.
String? adminRouteRedirect({
  required String path,
  required UserRole? role,
}) {
  final isAdminRoute = path == '/admin' || path.startsWith('/admin/');
  if (!isAdminRoute) return null;

  if (role == null) {
    return '/login';
  }

  if (role != UserRole.admin) {
    return '/home';
  }

  return null;
}
