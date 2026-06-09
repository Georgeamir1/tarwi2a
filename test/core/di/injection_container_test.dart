import 'package:flutter_test/flutter_test.dart';
import 'package:matbakhy/core/di/injection_container.dart';
import 'package:matbakhy/domain/repositories/auth_repository.dart';
import 'package:matbakhy/domain/repositories/profile_repository.dart';
import 'package:matbakhy/domain/repositories/category_repository.dart';
import 'package:matbakhy/domain/repositories/product_repository.dart';
import 'package:matbakhy/domain/repositories/order_repository.dart';
import 'package:matbakhy/domain/repositories/admin_repository.dart';
import 'package:matbakhy/domain/repositories/address_repository.dart';
import 'package:matbakhy/domain/repositories/coupon_repository.dart';
import 'package:matbakhy/domain/repositories/customer_repository.dart';
import 'package:matbakhy/domain/repositories/delivery_zone_repository.dart';
import 'package:matbakhy/domain/repositories/business_profile_repository.dart';
import 'package:matbakhy/domain/repositories/report_repository.dart';
import 'package:matbakhy/domain/repositories/product_option_repository.dart';
import 'package:matbakhy/domain/repositories/print_repository.dart';
import 'package:matbakhy/application/auth/auth_cubit.dart';
import 'package:matbakhy/application/menu/categories_cubit.dart';
import 'package:matbakhy/application/menu/products_cubit.dart';
import 'package:matbakhy/application/cart/cart_cubit.dart';
import 'package:matbakhy/application/orders/customer_orders_cubit.dart';
import 'package:matbakhy/application/admin/admin_orders_cubit.dart';
import 'package:matbakhy/application/admin/admin_categories_cubit.dart';
import 'package:matbakhy/application/admin/admin_products_cubit.dart';
import 'package:matbakhy/application/theme/theme_cubit.dart';
import 'package:matbakhy/application/address/address_cubit.dart';
import 'package:matbakhy/application/admin/admin_coupons_cubit.dart';
import 'package:matbakhy/application/admin/admin_customers_cubit.dart';
import 'package:matbakhy/application/admin/admin_delivery_zones_cubit.dart';
import 'package:matbakhy/application/admin/admin_business_profile_cubit.dart';
import 'package:matbakhy/application/admin/admin_reports_cubit.dart';
import 'package:matbakhy/application/admin/admin_product_options_cubit.dart';
import 'package:matbakhy/infrastructure/datasources/remote/auth_remote_data_source.dart';
import 'package:matbakhy/infrastructure/datasources/remote/profile_remote_data_source.dart';
import 'package:matbakhy/infrastructure/datasources/remote/category_remote_data_source.dart';
import 'package:matbakhy/infrastructure/datasources/remote/product_remote_data_source.dart';
import 'package:matbakhy/infrastructure/datasources/remote/order_remote_data_source.dart';
import 'package:matbakhy/infrastructure/datasources/local/cart_local_data_source.dart';
import 'package:matbakhy/infrastructure/datasources/remote/admin_remote_data_source.dart';
import 'package:matbakhy/infrastructure/datasources/remote/address_remote_data_source.dart';
import 'package:matbakhy/infrastructure/datasources/remote/coupon_remote_datasource.dart';
import 'package:matbakhy/infrastructure/datasources/remote/customer_remote_datasource.dart';
import 'package:matbakhy/infrastructure/datasources/remote/delivery_zone_remote_datasource.dart';
import 'package:matbakhy/infrastructure/datasources/remote/business_profile_remote_datasource.dart';
import 'package:matbakhy/infrastructure/datasources/remote/report_remote_datasource.dart';
import 'package:matbakhy/infrastructure/datasources/remote/product_option_remote_datasource.dart';
import 'package:matbakhy/core/services/thermal_printer_service.dart';

void main() {
  group('Dependency Injection', () {
    setUpAll(() async {
      await initDependencies();
    });

    tearDownAll(() async {
      await sl.reset();
    });

    test('initDependencies completed without error', () {
      expect(sl.isRegistered<AuthRepository>(), isTrue);
    });

    test('all repositories are registered', () {
      expect(sl.isRegistered<AuthRepository>(), isTrue);
      expect(sl.isRegistered<ProfileRepository>(), isTrue);
      expect(sl.isRegistered<CategoryRepository>(), isTrue);
      expect(sl.isRegistered<ProductRepository>(), isTrue);
      expect(sl.isRegistered<OrderRepository>(), isTrue);
      expect(sl.isRegistered<AdminRepository>(), isTrue);
      expect(sl.isRegistered<AddressRepository>(), isTrue);
      expect(sl.isRegistered<CouponRepository>(), isTrue);
      expect(sl.isRegistered<CustomerRepository>(), isTrue);
      expect(sl.isRegistered<DeliveryZoneRepository>(), isTrue);
      expect(sl.isRegistered<BusinessProfileRepository>(), isTrue);
      expect(sl.isRegistered<ReportRepository>(), isTrue);
      expect(sl.isRegistered<ProductOptionRepository>(), isTrue);
      expect(sl.isRegistered<PrintRepository>(), isTrue);
    });

    test('all cubits are registered', () {
      expect(sl.isRegistered<AuthCubit>(), isTrue);
      expect(sl.isRegistered<CategoriesCubit>(), isTrue);
      expect(sl.isRegistered<ProductsCubit>(), isTrue);
      expect(sl.isRegistered<CartCubit>(), isTrue);
      expect(sl.isRegistered<CustomerOrdersCubit>(), isTrue);
      expect(sl.isRegistered<AdminOrdersCubit>(), isTrue);
      expect(sl.isRegistered<AdminCategoriesCubit>(), isTrue);
      expect(sl.isRegistered<AdminProductsCubit>(), isTrue);
      expect(sl.isRegistered<ThemeCubit>(), isTrue);
      expect(sl.isRegistered<AddressCubit>(), isTrue);
      expect(sl.isRegistered<AdminCouponsCubit>(), isTrue);
      expect(sl.isRegistered<AdminCustomersCubit>(), isTrue);
      expect(sl.isRegistered<AdminDeliveryZonesCubit>(), isTrue);
      expect(sl.isRegistered<AdminBusinessProfileCubit>(), isTrue);
      expect(sl.isRegistered<AdminReportsCubit>(), isTrue);
      expect(sl.isRegistered<AdminProductOptionsCubit>(), isTrue);
    });

    test('all data sources are registered', () {
      expect(sl.isRegistered<AuthRemoteDataSource>(), isTrue);
      expect(sl.isRegistered<ProfileRemoteDataSource>(), isTrue);
      expect(sl.isRegistered<CategoryRemoteDataSource>(), isTrue);
      expect(sl.isRegistered<ProductRemoteDataSource>(), isTrue);
      expect(sl.isRegistered<OrderRemoteDataSource>(), isTrue);
      expect(sl.isRegistered<CartLocalDataSource>(), isTrue);
      expect(sl.isRegistered<AdminRemoteDataSource>(), isTrue);
      expect(sl.isRegistered<AddressRemoteDataSource>(), isTrue);
      expect(sl.isRegistered<CouponRemoteDataSource>(), isTrue);
      expect(sl.isRegistered<CustomerRemoteDataSource>(), isTrue);
      expect(sl.isRegistered<DeliveryZoneRemoteDataSource>(), isTrue);
      expect(sl.isRegistered<BusinessProfileRemoteDataSource>(), isTrue);
      expect(sl.isRegistered<ReportRemoteDataSource>(), isTrue);
      expect(sl.isRegistered<ProductOptionRemoteDataSource>(), isTrue);
    });

    test('all services are registered', () {
      expect(sl.isRegistered<ThermalPrinterService>(), isTrue);
    });
  });
}
