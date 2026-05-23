enum UserRole {
  customer('customer'),
  admin('admin');

  final String value;
  const UserRole(this.value);

  factory UserRole.fromString(String role) {
    return UserRole.values.firstWhere(
      (r) => r.value == role,
      orElse: () => UserRole.customer,
    );
  }

  bool get isAdmin => this == UserRole.admin;
}
