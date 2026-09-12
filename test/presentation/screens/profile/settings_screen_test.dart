import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:tarwi2a/core/di/injection_container.dart';
import 'package:tarwi2a/app/theme/app_theme.dart';
import 'package:tarwi2a/application/auth/auth_cubit.dart';
import 'package:tarwi2a/application/cart/cart_cubit.dart';
import 'package:tarwi2a/application/theme/theme_cubit.dart';
import 'package:tarwi2a/application/notifications/notifications_cubit.dart';
import 'package:tarwi2a/application/notifications/notification_preferences_cubit.dart';
import 'package:tarwi2a/domain/failures/failure.dart';
import 'package:tarwi2a/domain/repositories/auth_repository.dart';
import 'package:tarwi2a/core/services/biometric_service.dart';
import 'package:tarwi2a/core/services/push_notification_service.dart';
import 'package:tarwi2a/presentation/screens/profile/settings_screen.dart';
import '../../../helpers/test_helpers.dart';

class MockThemeCubit extends Mock implements ThemeCubit {}

class MockNotificationPreferencesCubit extends Mock
    implements NotificationPreferencesCubit {}

class MockBiometricService extends Mock implements BiometricService {}

class MockPushNotificationService extends Mock
    implements PushNotificationService {}

Widget _buildTestWidget({
  required AuthCubit authCubit,
  required ThemeCubit themeCubit,
  required NotificationPreferencesCubit prefsCubit,
  required CartCubit cartCubit,
}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthCubit>.value(value: authCubit),
      BlocProvider<ThemeCubit>.value(value: themeCubit),
      BlocProvider<NotificationPreferencesCubit>.value(value: prefsCubit),
      BlocProvider<CartCubit>.value(value: cartCubit),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const SettingsScreen(),
    ),
  );
}

void main() {
  late MockAuthCubit mockAuthCubit;
  late MockThemeCubit mockThemeCubit;
  late MockNotificationPreferencesCubit mockPrefsCubit;
  late MockCartCubit mockCartCubit;
  late MockNotificationsCubit mockNotificationsCubit;
  late MockBiometricService mockBiometricService;
  late MockPushNotificationService mockPushService;
  late MockAuthRepository mockAuthRepo;

  setUpAll(() {
    registerFallbackValue(testUserProfile);
  });

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    mockThemeCubit = MockThemeCubit();
    mockPrefsCubit = MockNotificationPreferencesCubit();
    mockCartCubit = MockCartCubit();
    mockNotificationsCubit = MockNotificationsCubit();
    mockBiometricService = MockBiometricService();
    mockPushService = MockPushNotificationService();
    mockAuthRepo = MockAuthRepository();

    when(() => mockThemeCubit.state).thenReturn(ThemeMode.light);
    when(() => mockThemeCubit.stream)
        .thenAnswer((_) => const Stream<ThemeMode>.empty());

    when(() => mockAuthCubit.state)
        .thenReturn(AuthState.authenticated(testUserProfile));
    when(() => mockAuthCubit.stream)
        .thenAnswer((_) => const Stream<AuthState>.empty());
    when(() => mockAuthCubit.deleteAccount())
        .thenAnswer((_) async => right<Failure, void>(null));

    when(() => mockCartCubit.state).thenReturn(const CartState());
    when(() => mockCartCubit.stream)
        .thenAnswer((_) => const Stream<CartState>.empty());
    when(() => mockCartCubit.clearCart()).thenReturn(null);

    when(() => mockNotificationsCubit.switchUser(any())).thenReturn(null);

    when(() => mockPrefsCubit.state)
        .thenReturn(NotificationPreferencesState.initial());
    when(() => mockPrefsCubit.stream)
        .thenAnswer((_) => const Stream<NotificationPreferencesState>.empty());
    when(() => mockPrefsCubit.loadPreferences(any())).thenAnswer((_) async {});

    when(() => mockBiometricService.isHardwareSupported)
        .thenAnswer((_) async => false);
    when(() => mockBiometricService.isEnabledForUser(any())).thenReturn(false);
    when(() => mockBiometricService.setEnabled(
          userId: any(named: 'userId'),
          enabled: any(named: 'enabled'),
        )).thenAnswer((_) async {});

    when(() => mockPushService.unregisterCurrentToken())
        .thenAnswer((_) async {});

    when(() => mockAuthRepo.currentUser).thenReturn(null);

    if (sl.isRegistered<BiometricService>()) {
      sl.unregister<BiometricService>();
    }
    sl.registerLazySingleton<BiometricService>(() => mockBiometricService);

    if (sl.isRegistered<PushNotificationService>()) {
      sl.unregister<PushNotificationService>();
    }
    sl.registerLazySingleton<PushNotificationService>(() => mockPushService);

    if (sl.isRegistered<AuthRepository>()) {
      sl.unregister<AuthRepository>();
    }
    sl.registerLazySingleton<AuthRepository>(() => mockAuthRepo);

    if (sl.isRegistered<NotificationsCubit>()) {
      sl.unregister<NotificationsCubit>();
    }
    sl.registerLazySingleton<NotificationsCubit>(() => mockNotificationsCubit);
  });

  testWidgets('SettingsScreen displays account deletion tile and opens dialog',
      (tester) async {
    await tester.pumpWidget(
      _buildTestWidget(
        authCubit: mockAuthCubit,
        themeCubit: mockThemeCubit,
        prefsCubit: mockPrefsCubit,
        cartCubit: mockCartCubit,
      ),
    );
    await tester.pumpAndSettle();

    final deleteTileFinder = find.text('طلب حذف الحساب');
    await tester.scrollUntilVisible(deleteTileFinder, 200);
    await tester.pumpAndSettle();

    // Verify delete account tile is rendered
    expect(deleteTileFinder, findsOneWidget);
    expect(
        find.text('حذف البيانات الشخصية وسجل الحساب نهائياً'), findsOneWidget);

    // Tap delete account tile
    await tester.tap(deleteTileFinder);
    await tester.pumpAndSettle();

    // Verify dialog appears with warning icon and destructive confirmation
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('تأكيد حذف الحساب نهائياً'), findsOneWidget);
    expect(
      find.textContaining(
          'سيؤدي هذا الإجراء إلى حذف بياناتك الشخصية وعناوين التوصيل'),
      findsOneWidget,
    );
    expect(find.text('إلغاء'), findsOneWidget);
    expect(find.text('تأكيد الحذف النهائي'), findsOneWidget);

    // Tap cancel
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets(
      'SettingsScreen confirms delete account successfully, invokes Cubit, and shows success SnackBar',
      (tester) async {
    when(() => mockAuthCubit.deleteAccount())
        .thenAnswer((_) async => right<Failure, void>(null));

    await tester.pumpWidget(
      _buildTestWidget(
        authCubit: mockAuthCubit,
        themeCubit: mockThemeCubit,
        prefsCubit: mockPrefsCubit,
        cartCubit: mockCartCubit,
      ),
    );
    await tester.pumpAndSettle();

    final deleteTileFinder = find.text('طلب حذف الحساب');
    await tester.scrollUntilVisible(deleteTileFinder, 200);
    await tester.pumpAndSettle();

    // Tap delete account tile
    await tester.tap(deleteTileFinder);
    await tester.pumpAndSettle();

    // Tap confirm final deletion
    await tester.tap(find.text('تأكيد الحذف النهائي'));
    await tester.pumpAndSettle();

    verify(() => mockAuthCubit.deleteAccount()).called(1);
    verify(() => mockBiometricService.setEnabled(
          userId: testUserProfile.id,
          enabled: false,
        )).called(1);
    verify(() => mockNotificationsCubit.switchUser(null)).called(1);
    verify(() => mockPushService.unregisterCurrentToken()).called(1);
    verify(() => mockCartCubit.clearCart()).called(1);

    expect(find.byType(AlertDialog), findsNothing);
    expect(
      find.text('تم حذف الحساب والبيانات الشخصية بنجاح'),
      findsOneWidget,
    );
  });

  testWidgets('Widget test proves failure never displays success',
      (tester) async {
    when(() => mockAuthCubit.deleteAccount()).thenAnswer(
      (_) async => left<Failure, void>(
        const Failure.server(message: 'فشل في الاتصال بالخادم لحذف الحساب'),
      ),
    );

    await tester.pumpWidget(
      _buildTestWidget(
        authCubit: mockAuthCubit,
        themeCubit: mockThemeCubit,
        prefsCubit: mockPrefsCubit,
        cartCubit: mockCartCubit,
      ),
    );
    await tester.pumpAndSettle();

    final deleteTileFinder = find.text('طلب حذف الحساب');
    await tester.scrollUntilVisible(deleteTileFinder, 200);
    await tester.pumpAndSettle();

    // Tap delete account tile
    await tester.tap(deleteTileFinder);
    await tester.pumpAndSettle();

    // Tap confirm final deletion
    await tester.tap(find.text('تأكيد الحذف النهائي'));
    await tester.pumpAndSettle();

    verify(() => mockAuthCubit.deleteAccount()).called(1);

    // Verify error message is shown
    expect(
      find.textContaining('فشل في الاتصال بالخادم لحذف الحساب'),
      findsOneWidget,
    );

    // Critical assertion: success message MUST NEVER be displayed
    expect(
      find.text('تم حذف الحساب والبيانات الشخصية بنجاح'),
      findsNothing,
    );
  });
}
