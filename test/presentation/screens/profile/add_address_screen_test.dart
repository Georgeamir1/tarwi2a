import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:tarwi2a/core/di/injection_container.dart';
import 'package:tarwi2a/app/theme/app_theme.dart';
import 'package:tarwi2a/application/auth/auth_cubit.dart';
import 'package:tarwi2a/application/address/address_cubit.dart';
import 'package:tarwi2a/domain/entities/address.dart';
import 'package:tarwi2a/domain/entities/delivery_zone.dart';
import 'package:tarwi2a/domain/repositories/delivery_zone_repository.dart';
import 'package:tarwi2a/presentation/screens/profile/add_address_screen.dart';
import 'package:tarwi2a/presentation/widgets/app_text_field.dart';
import '../../../helpers/test_helpers.dart';
import '../../../helpers/address_test_fakes.dart';

Widget _buildTestWidget({
  required AuthCubit authCubit,
  Address? addressToEdit,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: BlocProvider<AuthCubit>.value(
      value: authCubit,
      child: AddAddressScreen(addressToEdit: addressToEdit),
    ),
  );
}

void main() {
  late MockAuthCubit mockAuthCubit;
  late FakeAddressRepository fakeAddressRepo;
  late FakeDeliveryZoneRepository fakeZoneRepo;

  setUpAll(() {
    registerFallbackValue(testUserProfile);
    registerFallbackValue(testAddress);
  });

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    when(() => mockAuthCubit.state).thenReturn(
      AuthState.authenticated(testUserProfile),
    );
    when(() => mockAuthCubit.stream)
        .thenAnswer((_) => const Stream<AuthState>.empty());

    fakeAddressRepo = FakeAddressRepository();
    fakeZoneRepo = FakeDeliveryZoneRepository(
      getAllResult: right([testDeliveryZone]),
    );

    if (sl.isRegistered<DeliveryZoneRepository>()) {
      sl.unregister<DeliveryZoneRepository>();
    }
    sl.registerLazySingleton<DeliveryZoneRepository>(() => fakeZoneRepo);

    if (sl.isRegistered<AddressCubit>()) {
      sl.unregister<AddressCubit>();
    }
    sl.registerFactory<AddressCubit>(() => AddressCubit(fakeAddressRepo));
  });

  tearDown(() {
    if (sl.isRegistered<DeliveryZoneRepository>()) {
      sl.unregister<DeliveryZoneRepository>();
    }
    if (sl.isRegistered<AddressCubit>()) {
      sl.unregister<AddressCubit>();
    }
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    Address? addressToEdit,
  }) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      _buildTestWidget(
        authCubit: mockAuthCubit,
        addressToEdit: addressToEdit,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('AddAddressScreen', () {
    testWidgets(
        'shows failure snackbar and does not close screen when create fails',
        (tester) async {
      fakeAddressRepo.createAddressResult = left(testServerFailure);

      await pumpScreen(tester);

      // Select zone from dropdown
      final dropdown = find.byType(DropdownButtonFormField<DeliveryZone>);
      expect(dropdown, findsOneWidget);
      await tester.tap(dropdown);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text(testDeliveryZone.name).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Fill address field
      final addressField = find.descendant(
        of: find.widgetWithText(AppTextField, 'العنوان بالتفصيل'),
        matching: find.byType(TextFormField),
      );
      expect(addressField, findsOneWidget);
      await tester.enterText(addressField, 'شارع التحرير');
      await tester.pump();

      // Tap save button ('حفظ العنوان الجديد')
      final saveBtn = find.text('حفظ العنوان الجديد');
      expect(saveBtn, findsOneWidget);
      await tester.tap(saveBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Screen must still be open
      expect(find.text('حفظ العنوان الجديد'), findsOneWidget);
      // Failure snackbar must be visible
      expect(find.text(testServerFailure.message), findsOneWidget);
      // Input text preserved
      expect(find.text('شارع التحرير'), findsOneWidget);
    });

    testWidgets('pops screen with true when create succeeds', (tester) async {
      fakeAddressRepo.createAddressResult = right(testAddress);
      fakeAddressRepo.getAddressesResult = right([testAddress]);

      bool? poppedResult;
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute<bool>(
                      builder: (_) => BlocProvider<AuthCubit>.value(
                        value: mockAuthCubit,
                        child: const AddAddressScreen(),
                      ),
                    ),
                  );
                  poppedResult = result;
                },
                child: const Text('open'),
              );
            },
          ),
        ),
      );

      // Open screen
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Select zone
      final dropdown = find.byType(DropdownButtonFormField<DeliveryZone>);
      await tester.tap(dropdown);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text(testDeliveryZone.name).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Fill address
      final addressField = find.descendant(
        of: find.widgetWithText(AppTextField, 'العنوان بالتفصيل'),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(addressField, 'شارع التحرير');
      await tester.pump();

      // Save
      await tester.tap(find.text('حفظ العنوان الجديد'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(poppedResult, isTrue);
    });

    testWidgets('shows failure snackbar and does not close when edit fails',
        (tester) async {
      fakeAddressRepo.updateAddressResult = left(testServerFailure);
      final addressToEdit =
          testAddress.copyWith(deliveryZoneId: testDeliveryZone.id);

      await pumpScreen(tester, addressToEdit: addressToEdit);

      // Tap save ('تحديث العنوان')
      final saveBtn = find.text('تحديث العنوان');
      expect(saveBtn, findsOneWidget);
      await tester.tap(saveBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Screen still open
      expect(find.text('تحديث العنوان'), findsOneWidget);
      // Error message shown
      expect(find.text(testServerFailure.message), findsOneWidget);
    });

    testWidgets(
        'empty zones list does not crash when editing an address with zone',
        (tester) async {
      fakeZoneRepo.getAllResult = right([]);
      final addressWithZone = testAddress.copyWith(deliveryZoneId: 'zone-999');

      await pumpScreen(tester, addressToEdit: addressWithZone);

      // Verification that screen rendered successfully without crashing
      expect(find.text('تعديل العنوان'), findsOneWidget);
    });

    testWidgets('unknown zone id leaves selection null and does not crash',
        (tester) async {
      fakeZoneRepo.getAllResult = right([testDeliveryZone]);
      final addressWithUnknownZone =
          testAddress.copyWith(deliveryZoneId: 'zone-unknown');

      await pumpScreen(tester, addressToEdit: addressWithUnknownZone);

      expect(find.text('تعديل العنوان'), findsOneWidget);
    });
  });
}
