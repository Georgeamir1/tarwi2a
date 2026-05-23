import 'package:flutter/widgets.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'package:matbakhy/domain/repositories/auth_repository.dart';
import 'package:matbakhy/domain/repositories/profile_repository.dart';
import 'package:matbakhy/domain/repositories/category_repository.dart';
import 'package:matbakhy/domain/repositories/product_repository.dart';
import 'package:matbakhy/domain/repositories/order_repository.dart';
import 'package:matbakhy/domain/entities/user_profile.dart';
import 'package:matbakhy/domain/entities/category.dart';
import 'package:matbakhy/domain/entities/product.dart';
import 'package:matbakhy/domain/entities/cart_item.dart';
import 'package:matbakhy/domain/entities/order.dart';
import 'package:matbakhy/domain/entities/order_item.dart';
import 'package:matbakhy/domain/entities/coupon.dart';
import 'package:matbakhy/domain/entities/customer.dart';
import 'package:matbakhy/domain/entities/delivery_zone.dart';
import 'package:matbakhy/domain/entities/business_profile.dart';
import 'package:matbakhy/domain/entities/product_option.dart';
import 'package:matbakhy/domain/enums/user_role.dart';
import 'package:matbakhy/domain/enums/order_status.dart';
import 'package:matbakhy/domain/enums/payment_method.dart';
import 'package:matbakhy/domain/enums/coupon_type.dart';
import 'package:matbakhy/domain/failures/failure.dart';
import 'package:matbakhy/infrastructure/datasources/remote/auth_remote_data_source.dart';
import 'package:matbakhy/infrastructure/datasources/remote/category_remote_data_source.dart';
import 'package:matbakhy/infrastructure/datasources/remote/product_remote_data_source.dart';
import 'package:matbakhy/infrastructure/datasources/remote/order_remote_data_source.dart';
import 'package:matbakhy/application/auth/auth_cubit.dart';
import 'package:matbakhy/application/menu/categories_cubit.dart';
import 'package:matbakhy/application/menu/products_cubit.dart';
import 'package:matbakhy/application/cart/cart_cubit.dart';
import 'package:matbakhy/application/orders/customer_orders_cubit.dart';
import 'package:matbakhy/application/admin/admin_orders_cubit.dart';
import 'package:matbakhy/application/admin/admin_categories_cubit.dart';
import 'package:matbakhy/application/admin/admin_products_cubit.dart';
import 'package:matbakhy/domain/repositories/coupon_repository.dart';
import 'package:matbakhy/domain/repositories/customer_repository.dart';
import 'package:matbakhy/domain/repositories/delivery_zone_repository.dart';
import 'package:matbakhy/domain/repositories/business_profile_repository.dart';
import 'package:matbakhy/domain/repositories/report_repository.dart';
import 'package:matbakhy/domain/repositories/product_option_repository.dart';
import 'package:matbakhy/domain/repositories/print_repository.dart';

// --- Mock Supabase types ---

class MockAuthResponse extends Mock implements AuthResponse {}

class MockUser extends Mock implements User {}

class MockSession extends Mock implements Session {}

class FakeRoute extends Fake implements Route<dynamic> {}

// --- Mock Data Sources ---

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockCategoryRemoteDataSource extends Mock
    implements CategoryRemoteDataSource {}

class MockProductRemoteDataSource extends Mock
    implements ProductRemoteDataSource {}

class MockOrderRemoteDataSource extends Mock implements OrderRemoteDataSource {}

// --- Mock Repositories ---

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

class MockOrderRepository extends Mock implements OrderRepository {}

// --- Mock Cubits ---

class MockAuthCubit extends Mock implements AuthCubit {}

class MockCategoriesCubit extends Mock implements CategoriesCubit {}

class MockProductsCubit extends Mock implements ProductsCubit {}

class MockCartCubit extends Mock implements CartCubit {}

class MockCustomerOrdersCubit extends Mock implements CustomerOrdersCubit {}

class MockAdminOrdersCubit extends Mock implements AdminOrdersCubit {}

class MockAdminCategoriesCubit extends Mock implements AdminCategoriesCubit {}

class MockAdminProductsCubit extends Mock implements AdminProductsCubit {}

class MockCouponRepository extends Mock implements CouponRepository {}

class MockCustomerRepository extends Mock implements CustomerRepository {}

class MockDeliveryZoneRepository extends Mock
    implements DeliveryZoneRepository {}

class MockBusinessProfileRepository extends Mock
    implements BusinessProfileRepository {}

class MockReportRepository extends Mock implements ReportRepository {}

class MockProductOptionRepository extends Mock
    implements ProductOptionRepository {}

class MockPrintRepository extends Mock implements PrintRepository {}

// --- Test Fixtures ---

final testUserProfile = UserProfile(
  id: 'user-123',
  name: 'محمد',
  phone: '01001234567',
  role: UserRole.customer,
  createdAt: DateTime(2026, 1, 1),
);

final testAdminProfile = UserProfile(
  id: 'admin-456',
  name: 'مدير',
  phone: '01009876543',
  role: UserRole.admin,
  createdAt: DateTime(2026, 1, 1),
);

const testServerFailure = Failure.server(
  message: 'حدث خطأ في السيرفر',
);

const testNetworkFailure = Failure.network(
  message: 'لا يوجد اتصال بالإنترنت',
);

const testValidationFailure = Failure.validation(
  message: 'حقل مطلوب',
  field: 'email',
);

final testUnexpectedFailure = Failure.unexpected(
  message: Exception().toString(),
);

const testCategory = Category(
  id: 'cat-1',
  name: 'Pizza',
  nameAr: 'بيتزا',
  imageUrl: 'https://example.com/pizza.png',
  sortOrder: 1,
  isActive: true,
);

const testProduct = Product(
  id: 'prod-1',
  categoryId: 'cat-1',
  name: 'Margherita',
  nameAr: 'مارجريتا',
  description: 'Cheese and tomato',
  descriptionAr: 'جبنة و طماطم',
  price: 75.0,
  imageUrl: 'https://example.com/margherita.png',
  isAvailable: true,
  sortOrder: 1,
);

const testCartItem = CartItem(
  productId: 'prod-1',
  productNameAr: 'مارجريتا',
  productPrice: 75.0,
  quantity: 2,
);

const testOrderItem = OrderItem(
  id: 'oi-1',
  orderId: 'order-1',
  productId: 'prod-1',
  productName: 'مارجريتا',
  productPrice: 75.0,
  quantity: 2,
  subtotal: 150.0,
);

final testOrder = Order(
  id: 'order-1',
  customerId: 'user-123',
  customerName: 'محمد',
  customerPhone: '01001234567',
  customerAddress: 'القاهرة',
  notes: 'بدون بصل',
  paymentMethod: PaymentMethod.cash,
  status: OrderStatus.pending,
  totalAmount: 150.0,
  createdAt: DateTime(2026, 5, 1, 10, 0),
  updatedAt: DateTime(2026, 5, 1, 10, 0),
  items: [testOrderItem],
);

final testDeliveredOrder = Order(
  id: 'order-2',
  customerId: 'user-456',
  customerName: 'أحمد',
  customerPhone: '0100999888',
  paymentMethod: PaymentMethod.wallet,
  status: OrderStatus.delivered,
  totalAmount: 200.0,
  createdAt: DateTime(2026, 5, 10, 14, 0),
  updatedAt: DateTime(2026, 5, 10, 14, 30),
  items: [testOrderItem],
);

final testDateTime = DateTime(2026, 1, 1);

final testCoupon = Coupon(
  id: 'coupon-1',
  code: 'WELCOME20',
  type: CouponType.percentage,
  value: 20,
  minOrder: 100,
  maxUses: 50,
  usedCount: 5,
  isActive: true,
  createdAt: testDateTime,
);

final testCustomer = Customer(
  id: 'cust-1',
  name: 'محمد',
  phone: '01001234567',
  role: UserRole.customer,
  totalOrders: 12,
  totalSpent: 3500.0,
  lastOrderAt: DateTime(2026, 5, 15),
  createdAt: DateTime(2026, 1, 1),
);

final testDeliveryZone = DeliveryZone(
  id: 'zone-1',
  name: 'وسط البلد',
  fee: 25.0,
  minOrderAmount: 50,
  estimatedTime: '30-45 دقيقة',
  isActive: true,
  createdAt: testDateTime,
);

final testBusinessProfile = BusinessProfile(
  id: 'bp-1',
  name: 'ترويقه',
  phone: '+201000000000',
  address: 'القاهرة، مصر',
  openingHours: const {
    'saturday': OpeningPeriod(open: '10:00', close: '22:00'),
  },
  minOrder: 50,
  defaultPrepTime: 30,
  isBusy: false,
  acceptOrders: true,
  updatedAt: DateTime(2026, 5, 1),
);

final testReportData = ReportData(
  totalRevenue: 15000.0,
  totalOrders: 85,
  averageOrder: 176.5,
  cancelledOrders: 3,
  revenueByDay: [
    DailyRevenue(date: testDateTime, revenue: 2500, orderCount: 15),
  ],
  topProducts: [
    const TopProduct(
        productId: 'p1', name: 'بيتزا', quantity: 40, revenue: 3200),
  ],
  totalCustomers: 120,
  discountTotal: 500,
);

const testProductOption = ProductOption(
  id: 'opt-1',
  productId: 'prod-1',
  name: 'Extra Cheese',
  nameAr: 'جبنة إضافية',
  priceDelta: 10.0,
  isRequired: false,
  maxSelections: 1,
  sortOrder: 0,
);
