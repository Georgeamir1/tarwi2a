class AppConstants {
  // Supabase - Loaded from environment variables (--dart-define or .env)
  // In development: flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  // In CI/CD: Set these as GitHub Secrets and pass as --dart-define in workflow
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://placeholder.supabase.co',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'placeholder-key',
  );

  // App
  static const appName = 'ترويقه';

  // Payment Methods
  static const paymentCash = 'cash';
  static const paymentWallet = 'wallet';
  static const paymentInstapay = 'instapay';

  // Order Status
  static const statusPending = 'pending';
  static const statusConfirmed = 'confirmed';
  static const statusPreparing = 'preparing';
  static const statusReady = 'ready';
  static const statusDelivered = 'delivered';
  static const statusCancelled = 'cancelled';

  // Roles
  static const roleCustomer = 'customer';
  static const roleAdmin = 'admin';
}
