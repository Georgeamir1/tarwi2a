import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/di/injection_container.dart';
import 'app/theme/app_theme.dart';
import 'router/app_router.dart';
import 'application/auth/auth_cubit.dart';
import 'application/cart/cart_cubit.dart';
import 'application/theme/theme_cubit.dart';
import 'application/orders/customer_orders_cubit.dart';
import 'application/admin/admin_reports_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Sentry (crash reporting)
  // Set SENTRY_DSN environment variable or use --dart-define
  final sentryDsn = const String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );
  if (sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 0.1;
        options.sampleRate = 0.1;
      },
    );
  }

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  await initDependencies();
  runApp(const TarwikaApp());
}

class TarwikaApp extends StatefulWidget {
  const TarwikaApp({super.key});

  @override
  State<TarwikaApp> createState() => _TarwikaAppState();
}

class _TarwikaAppState extends State<TarwikaApp> {
  late final ThemeCubit _themeCubit;

  @override
  void initState() {
    super.initState();
    _themeCubit = sl<ThemeCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthCubit>()..checkAuthStatus()),
        BlocProvider(create: (_) => sl<CartCubit>()..loadCart()),
        BlocProvider.value(value: sl<CustomerOrdersCubit>()),
        BlocProvider.value(value: sl<AdminReportsCubit>()),
        BlocProvider.value(value: _themeCubit),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.light,
            routerConfig: appRouter,
            builder: (context, child) => Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            ),
          );
        },
      ),
    );
  }
}
