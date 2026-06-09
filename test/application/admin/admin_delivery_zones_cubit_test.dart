import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:matbakhy/application/admin/admin_delivery_zones_cubit.dart';
import 'package:matbakhy/domain/entities/delivery_zone.dart';
import 'package:matbakhy/domain/failures/failure.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late MockDeliveryZoneRepository mockRepo;
  late AdminDeliveryZonesCubit cubit;

  setUpAll(() {
    registerFallbackValue(<DeliveryZone>[]);
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockRepo = MockDeliveryZoneRepository();
    when(() => mockRepo.watchDeliveryZones())
        .thenAnswer((_) => const Stream.empty());
  });

  group('AdminDeliveryZonesCubit', () {
    group('initial state', () {
      test('emits initial with empty zones', () {
        cubit = AdminDeliveryZonesCubit(mockRepo);
        expect(cubit.state.status, AdminDeliveryZonesStatus.initial);
        expect(cubit.state.zones, isEmpty);
      });
    });

    group('loadZones', () {
      test('emits loading then loaded with data on success', () async {
        when(() => mockRepo.getAll())
            .thenAnswer((_) async => right([testDeliveryZone]));

        cubit = AdminDeliveryZonesCubit(mockRepo);
        await cubit.loadZones();

        expect(cubit.state.status, AdminDeliveryZonesStatus.loaded);
        expect(cubit.state.zones, [testDeliveryZone]);
      });

      test('emits loading then error on failure', () async {
        when(() => mockRepo.getAll())
            .thenAnswer((_) async => left(testServerFailure));

        cubit = AdminDeliveryZonesCubit(mockRepo);
        await cubit.loadZones();

        expect(cubit.state.status, AdminDeliveryZonesStatus.error);
        expect(cubit.state.failure, testServerFailure);
      });
    });

    group('upsert', () {
      test('emits loading then loaded on success', () async {
        when(() => mockRepo.upsert(any(), id: any(named: 'id')))
            .thenAnswer((_) async => right<Failure, void>(null));
        when(() => mockRepo.getAll())
            .thenAnswer((_) async => right([testDeliveryZone]));

        cubit = AdminDeliveryZonesCubit(mockRepo);
        await cubit.upsert({'name': 'جديد', 'fee': 30});
        await Future.delayed(const Duration(milliseconds: 50));

        expect(cubit.state.status, AdminDeliveryZonesStatus.loaded);
        verify(() => mockRepo.upsert(any(), id: any(named: 'id'))).called(1);
      });

      test('emits loading then error on failure', () async {
        when(() => mockRepo.upsert(any(), id: any(named: 'id')))
            .thenAnswer((_) async => left(testServerFailure));

        cubit = AdminDeliveryZonesCubit(mockRepo);
        await cubit.upsert({'name': 'جديد'});

        expect(cubit.state.status, AdminDeliveryZonesStatus.error);
      });
    });

    group('toggleActive', () {
      test('emits loading then loaded on success', () async {
        when(() => mockRepo.toggleActive('zone-1', false))
            .thenAnswer((_) async => right<Failure, void>(null));
        when(() => mockRepo.getAll())
            .thenAnswer((_) async => right([testDeliveryZone]));

        cubit = AdminDeliveryZonesCubit(mockRepo);
        await cubit.toggleActive('zone-1', false);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(cubit.state.status, AdminDeliveryZonesStatus.loaded);
      });

      test('emits loading then error on failure', () async {
        when(() => mockRepo.toggleActive('zone-1', false))
            .thenAnswer((_) async => left(testServerFailure));

        cubit = AdminDeliveryZonesCubit(mockRepo);
        await cubit.toggleActive('zone-1', false);

        expect(cubit.state.status, AdminDeliveryZonesStatus.error);
      });
    });

    group('delete', () {
      test('emits loading then loaded on success', () async {
        when(() => mockRepo.delete('zone-1'))
            .thenAnswer((_) async => right<Failure, void>(null));
        when(() => mockRepo.getAll())
            .thenAnswer((_) async => right(<DeliveryZone>[]));

        cubit = AdminDeliveryZonesCubit(mockRepo);
        await cubit.delete('zone-1');
        await Future.delayed(const Duration(milliseconds: 50));

        expect(cubit.state.status, AdminDeliveryZonesStatus.loaded);
        expect(cubit.state.zones, isEmpty);
      });

      test('emits loading then error on failure', () async {
        when(() => mockRepo.delete('zone-1'))
            .thenAnswer((_) async => left(testServerFailure));

        cubit = AdminDeliveryZonesCubit(mockRepo);
        await cubit.delete('zone-1');

        expect(cubit.state.status, AdminDeliveryZonesStatus.error);
      });
    });

    group('realtime subscription', () {
      test('updates zones when stream emits', () async {
        final controller = StreamController<List<DeliveryZone>>.broadcast();
        when(() => mockRepo.getAll())
            .thenAnswer((_) async => right([testDeliveryZone]));
        when(() => mockRepo.watchDeliveryZones())
            .thenAnswer((_) => controller.stream);

        cubit = AdminDeliveryZonesCubit(mockRepo);
        await cubit.loadZones();

        final updatedZone = testDeliveryZone.copyWith(fee: 35);
        controller.add([updatedZone]);

        await Future.delayed(const Duration(milliseconds: 50));

        expect(cubit.state.zones, [updatedZone]);
        expect(cubit.state.status, AdminDeliveryZonesStatus.loaded);

        await controller.close();
      });

      test('cancels subscription on close', () async {
        final controller = StreamController<List<DeliveryZone>>.broadcast();
        when(() => mockRepo.getAll())
            .thenAnswer((_) async => right([testDeliveryZone]));
        when(() => mockRepo.watchDeliveryZones())
            .thenAnswer((_) => controller.stream);

        cubit = AdminDeliveryZonesCubit(mockRepo);
        await cubit.loadZones();
        await cubit.close();

        expect(controller.hasListener, isFalse);
        await controller.close();
      });
    });
  });
}
