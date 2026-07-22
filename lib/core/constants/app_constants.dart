class AppConstants {
  // Supabase - Loaded from environment variables (--dart-define or .env)
  // In development: flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  // In CI/CD: Set these as GitHub Secrets and pass as --dart-define in workflow
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://tfchunxrymewqfbafhnb.supabase.co',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRmY2h1bnhyeW1ld3FmYmFmaG5iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM5MTkzMTIsImV4cCI6MjA4OTQ5NTMxMn0.J0VYzLmnA4htPbOnO7bxgctVpuCwDAwms_gMQdB-gLg',
  );

  // App
  static const appName = 'ترويئه';

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
