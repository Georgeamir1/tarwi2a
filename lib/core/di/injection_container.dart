import 'package:get_it/get_it.dart';
import '../../router/app_router.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../infrastructure/datasources/remote/auth_remote_data_source.dart';
import '../../infrastructure/datasources/remote/profile_remote_data_source.dart';
import '../../infrastructure/datasources/remote/category_remote_data_source.dart';
import '../../infrastructure/datasources/remote/product_remote_data_source.dart';
import '../../infrastructure/datasources/remote/order_remote_data_source.dart';
import '../../infrastructure/datasources/local/cart_local_data_source.dart';
import '../../infrastructure/datasources/remote/admin_remote_data_source.dart';
import '../../infrastructure/datasources/remote/address_remote_data_source.dart';
import '../../infrastructure/datasources/remote/coupon_remote_datasource.dart';
import '../../infrastructure/datasources/remote/customer_remote_datasource.dart';
import '../../infrastructure/datasources/remote/delivery_zone_remote_datasource.dart';
import '../../infrastructure/datasources/remote/business_profile_remote_datasource.dart';
import '../../infrastructure/datasources/remote/report_remote_datasource.dart';
import '../../infrastructure/datasources/remote/product_option_remote_datasource.dart';
import '../../infrastructure/datasources/remote/notification_remote_datasource.dart';
import '../../infrastructure/datasources/remote/device_token_remote_datasource.dart';
import '../../infrastructure/datasources/remote/broadcast_remote_datasource.dart';
import '../../infrastructure/repositories/admin_repository_impl.dart';
import '../../infrastructure/repositories/address_repository_impl.dart';
import '../../infrastructure/repositories/coupon_repository_impl.dart';
import '../../infrastructure/repositories/customer_repository_impl.dart';
import '../../infrastructure/repositories/delivery_zone_repository_impl.dart';
import '../../infrastructure/repositories/business_profile_repository_impl.dart';
import '../../infrastructure/repositories/report_repository_impl.dart';
import '../../infrastructure/repositories/product_option_repository_impl.dart';
import '../../infrastructure/repositories/print_repository_impl.dart';
import '../../infrastructure/repositories/notification_repository_impl.dart';
import '../../infrastructure/repositories/device_token_repository_impl.dart';
import '../../infrastructure/repositories/broadcast_repository_impl.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../domain/repositories/address_repository.dart';
import '../../domain/repositories/coupon_repository.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/delivery_zone_repository.dart';
import '../../domain/repositories/business_profile_repository.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/repositories/product_option_repository.dart';
import '../../domain/repositories/print_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/device_token_repository.dart';
import '../../domain/repositories/broadcast_repository.dart';
import '../../infrastructure/repositories/auth_repository_impl.dart';
import '../../infrastructure/repositories/profile_repository_impl.dart';
import '../../infrastructure/repositories/category_repository_impl.dart';
import '../../infrastructure/repositories/product_repository_impl.dart';
import '../../infrastructure/repositories/order_repository_impl.dart';
import '../../application/auth/auth_cubit.dart';
import '../../application/menu/categories_cubit.dart';
import '../../application/menu/products_cubit.dart';
import '../../application/cart/cart_cubit.dart';
import '../../application/orders/customer_orders_cubit.dart';
import '../../application/admin/admin_orders_cubit.dart';
import '../../application/admin/admin_categories_cubit.dart';
import '../../application/admin/admin_products_cubit.dart';
import '../../application/theme/theme_cubit.dart';
import '../../application/address/address_cubit.dart';
import '../../application/coupon/coupon_cubit.dart';
import '../../application/admin/admin_coupons_cubit.dart';
import '../../application/admin/admin_customers_cubit.dart';
import '../../application/admin/admin_delivery_zones_cubit.dart';
import '../../application/admin/admin_business_profile_cubit.dart';
import '../../application/admin/admin_reports_cubit.dart';
import '../../application/admin/admin_product_options_cubit.dart';
import '../../application/notifications/notifications_cubit.dart';
import '../../application/notifications/notification_preferences_cubit.dart';
import '../../application/admin/admin_broadcast_cubit.dart';
import '../../core/services/thermal_printer_service.dart';
import '../../core/services/device_token_service.dart';
import '../../core/services/push_notification_service.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Data Sources (lazy singletons - stateless)
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource());
  sl.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSource());
  sl.registerLazySingleton<CategoryRemoteDataSource>(
      () => CategoryRemoteDataSource());
  sl.registerLazySingleton<ProductRemoteDataSource>(
      () => ProductRemoteDataSource());
  sl.registerLazySingleton<OrderRemoteDataSource>(
      () => OrderRemoteDataSource());
  sl.registerLazySingleton<CartLocalDataSource>(() => CartLocalDataSource());
  sl.registerLazySingleton<AdminRemoteDataSource>(
      () => AdminRemoteDataSource());
  sl.registerLazySingleton<AddressRemoteDataSource>(
      () => AddressRemoteDataSource());
  sl.registerLazySingleton<CouponRemoteDataSource>(
      () => CouponRemoteDataSource());
  sl.registerLazySingleton<CustomerRemoteDataSource>(
      () => CustomerRemoteDataSource());
  sl.registerLazySingleton<DeliveryZoneRemoteDataSource>(
      () => DeliveryZoneRemoteDataSource());
  sl.registerLazySingleton<BusinessProfileRemoteDataSource>(
      () => BusinessProfileRemoteDataSource());
  sl.registerLazySingleton<ReportRemoteDataSource>(
      () => ReportRemoteDataSource());
  sl.registerLazySingleton<ProductOptionRemoteDataSource>(
      () => ProductOptionRemoteDataSource());
  sl.registerLazySingleton<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSource());
  sl.registerLazySingleton<DeviceTokenRemoteDataSource>(
      () => DeviceTokenRemoteDataSource());
  sl.registerLazySingleton<BroadcastRemoteDataSource>(
      () => BroadcastRemoteDataSource());

  // Repositories (lazy singletons)
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl()));
  sl.registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(sl()));
  sl.registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(sl()));
  sl.registerLazySingleton<OrderRepository>(() => OrderRepositoryImpl(sl()));
  sl.registerLazySingleton<AdminRepository>(() => AdminRepositoryImpl(sl()));
  sl.registerLazySingleton<AddressRepository>(
      () => AddressRepositoryImpl(sl()));
  sl.registerLazySingleton<CouponRepository>(() => CouponRepositoryImpl(sl()));
  sl.registerLazySingleton<CustomerRepository>(
      () => CustomerRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<DeliveryZoneRepository>(
      () => DeliveryZoneRepositoryImpl(sl()));
  sl.registerLazySingleton<BusinessProfileRepository>(
      () => BusinessProfileRepositoryImpl(sl()));
  sl.registerLazySingleton<ReportRepository>(() => ReportRepositoryImpl(sl()));
  sl.registerLazySingleton<ProductOptionRepository>(
      () => ProductOptionRepositoryImpl(sl()));
  sl.registerLazySingleton<ThermalPrinterService>(
      () => ThermalPrinterService());
  sl.registerLazySingleton<PrintRepository>(() => PrintRepositoryImpl(sl()));
  sl.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(sl()));
  sl.registerLazySingleton<DeviceTokenRepository>(
      () => DeviceTokenRepositoryImpl(sl()));
  sl.registerLazySingleton<BroadcastRepository>(
      () => BroadcastRepositoryImpl(sl()));
  sl.registerLazySingleton<DeviceTokenService>(() => DeviceTokenService(sl()));
  sl.registerLazySingleton<PushNotificationService>(
      () => PushNotificationService(
            deviceTokenService: sl<DeviceTokenService>(),
            routerProvider: () => appRouter,
          ));

  // Cubits (factory - new instance per scope)
  sl.registerLazySingleton<AuthCubit>(
      () => AuthCubit(authRepository: sl(), profileRepository: sl()));
  sl.registerFactory<CategoriesCubit>(() => CategoriesCubit(sl()));
  sl.registerFactory<ProductsCubit>(() => ProductsCubit(sl()));
  sl.registerFactory<CartCubit>(() => CartCubit(sl()));
  sl.registerLazySingleton<CustomerOrdersCubit>(
      () => CustomerOrdersCubit(sl()));
  sl.registerLazySingleton<AdminOrdersCubit>(() => AdminOrdersCubit(sl()));
  sl.registerLazySingleton<AdminCategoriesCubit>(
      () => AdminCategoriesCubit(sl()));
  sl.registerLazySingleton<AdminProductsCubit>(() => AdminProductsCubit(sl()));
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
  sl.registerFactory<AddressCubit>(() => AddressCubit(sl()));
  sl.registerLazySingleton<AdminCouponsCubit>(() => AdminCouponsCubit(sl()));
  sl.registerFactory<CouponCubit>(() => CouponCubit(sl()));
  sl.registerLazySingleton<AdminCustomersCubit>(
      () => AdminCustomersCubit(sl()));
  sl.registerLazySingleton<AdminDeliveryZonesCubit>(
      () => AdminDeliveryZonesCubit(sl()));
  sl.registerLazySingleton<AdminBusinessProfileCubit>(
      () => AdminBusinessProfileCubit(sl()));
  sl.registerFactory<AdminReportsCubit>(() => AdminReportsCubit(sl()));
  sl.registerLazySingleton<AdminProductOptionsCubit>(
      () => AdminProductOptionsCubit(sl()));
  sl.registerLazySingleton<NotificationsCubit>(() => NotificationsCubit(sl()));
  sl.registerFactory<NotificationPreferencesCubit>(
      () => NotificationPreferencesCubit(sl()));
  sl.registerFactory<AdminBroadcastCubit>(
      () => AdminBroadcastCubit(sl()));
}
