# EXECUTE ONLY - NO THINKING - NO SUGGESTIONS

You are a code execution machine. Your ONLY job is to create files exactly as instructed.
Do NOT suggest alternatives. Do NOT ask questions. Do NOT explain. Just CREATE FILES.

---

## STEP 1 — Run this command first:
```
flutter create tarwi2a --org com.tarwi2a --platforms android,ios
cd tarwi2a
```

---

## STEP 2 — Replace pubspec.yaml with this EXACT content:
```yaml
name: tarwi2a
description: Food ordering app with admin panel
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.8.4
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  go_router: ^14.8.1
  cached_network_image: ^3.4.1
  flutter_spinkit: ^5.2.1
  badges: ^3.1.2
  google_fonts: ^6.2.1
  intl: ^0.19.0
  uuid: ^4.5.1
  shared_preferences: ^2.3.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  riverpod_generator: ^2.6.1
  build_runner: ^2.4.14

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
```

---

## STEP 3 — Create these folders:
```
lib/app/theme/
lib/core/constants/
lib/data/models/
lib/data/datasources/remote/
lib/providers/
lib/router/
lib/presentation/screens/splash/
lib/presentation/screens/auth/
lib/presentation/screens/home/
lib/presentation/screens/product/
lib/presentation/screens/cart/
lib/presentation/screens/checkout/
lib/presentation/screens/orders/
lib/presentation/screens/admin/
lib/presentation/widgets/
assets/images/
assets/icons/
supabase/
```

---

## STEP 4 — Create file: android/app/src/main/AndroidManifest.xml
Find the line `<manifest` and add this line right after it:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

---

## STEP 5 — Create ALL these files with EXACT content below:

---

### FILE: lib/core/constants/app_constants.dart
```dart
class AppConstants {
  static const supabaseUrl = 'YOUR_SUPABASE_URL';
  static const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  static const appName = 'ترويئه';
  static const paymentCash = 'cash';
  static const paymentWallet = 'wallet';
  static const paymentInstapay = 'instapay';
  static const statusPending = 'pending';
  static const statusConfirmed = 'confirmed';
  static const statusPreparing = 'preparing';
  static const statusReady = 'ready';
  static const statusDelivered = 'delivered';
  static const statusCancelled = 'cancelled';
  static const roleCustomer = 'customer';
  static const roleAdmin = 'admin';
}
```

---

### FILE: lib/app/theme/app_theme.dart
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFFFF6B35);
  static const primaryDark = Color(0xFFE85A20);
  static const secondary = Color(0xFF2D3436);
  static const background = Color(0xFFF8F9FA);
  static const surface = Colors.white;
  static const error = Color(0xFFE74C3C);
  static const success = Color(0xFF27AE60);
  static const warning = Color(0xFFF39C12);
  static const textPrimary = Color(0xFF2D3436);
  static const textSecondary = Color(0xFF636E72);
  static const divider = Color(0xFFDFE6E9);
  static const statusPending = Color(0xFFF39C12);
  static const statusConfirmed = Color(0xFF3498DB);
  static const statusPreparing = Color(0xFF9B59B6);
  static const statusReady = Color(0xFF27AE60);
  static const statusDelivered = Color(0xFF2ECC71);
  static const statusCancelled = Color(0xFFE74C3C);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.cairoTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: GoogleFonts.cairo(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
    );
  }
}
```

---

### FILE: lib/data/models/models.dart
```dart
class UserProfile {
  final String id;
  final String name;
  final String? phone;
  final String role;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.name,
    this.phone,
    required this.role,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'customer',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'phone': phone, 'role': role,
  };

  UserProfile copyWith({String? name, String? phone}) {
    return UserProfile(id: id, name: name ?? this.name,
      phone: phone ?? this.phone, role: role, createdAt: createdAt);
  }
}

class Category {
  final String id;
  final String name;
  final String nameAr;
  final String? imageUrl;
  final int sortOrder;
  final bool isActive;

  const Category({required this.id, required this.name, required this.nameAr,
    this.imageUrl, required this.sortOrder, required this.isActive});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAr: json['name_ar'] as String,
      imageUrl: json['image_url'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name, 'name_ar': nameAr, 'image_url': imageUrl,
    'sort_order': sortOrder, 'is_active': isActive,
  };
}

class Product {
  final String id;
  final String? categoryId;
  final String name;
  final String nameAr;
  final String? description;
  final String? descriptionAr;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final int sortOrder;

  const Product({required this.id, this.categoryId, required this.name,
    required this.nameAr, this.description, this.descriptionAr,
    required this.price, this.imageUrl, required this.isAvailable,
    required this.sortOrder});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      categoryId: json['category_id'] as String?,
      name: json['name'] as String,
      nameAr: json['name_ar'] as String,
      description: json['description'] as String?,
      descriptionAr: json['description_ar'] as String?,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'category_id': categoryId, 'name': name, 'name_ar': nameAr,
    'description': description, 'description_ar': descriptionAr,
    'price': price, 'image_url': imageUrl,
    'is_available': isAvailable, 'sort_order': sortOrder,
  };
}

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  double get subtotal => product.price * quantity;

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);
}

class Order {
  final String id;
  final String? customerId;
  final String customerName;
  final String customerPhone;
  final String? customerAddress;
  final String? notes;
  final String paymentMethod;
  final String status;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;

  const Order({required this.id, this.customerId, required this.customerName,
    required this.customerPhone, this.customerAddress, this.notes,
    required this.paymentMethod, required this.status,
    required this.totalAmount, required this.createdAt,
    required this.updatedAt, this.items = const []});

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['order_items'] as List<dynamic>? ?? [];
    return Order(
      id: json['id'] as String,
      customerId: json['customer_id'] as String?,
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String,
      customerAddress: json['customer_address'] as String?,
      notes: json['notes'] as String?,
      paymentMethod: json['payment_method'] as String,
      status: json['status'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      items: itemsJson.map((e) => OrderItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  String get statusAr {
    switch (status) {
      case 'pending': return 'في الانتظار';
      case 'confirmed': return 'تم التأكيد';
      case 'preparing': return 'جاري التحضير';
      case 'ready': return 'جاهز للاستلام';
      case 'delivered': return 'تم التوصيل';
      case 'cancelled': return 'ملغي';
      default: return status;
    }
  }

  String get paymentMethodAr {
    switch (paymentMethod) {
      case 'cash': return 'كاش';
      case 'wallet': return 'محفظة';
      case 'instapay': return 'انستا باي';
      default: return paymentMethod;
    }
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String? productId;
  final String productName;
  final double productPrice;
  final int quantity;
  final double subtotal;

  const OrderItem({required this.id, required this.orderId, this.productId,
    required this.productName, required this.productPrice,
    required this.quantity, required this.subtotal});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String?,
      productName: json['product_name'] as String,
      productPrice: (json['product_price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }
}
```

---

### FILE: lib/data/datasources/remote/supabase_datasource.dart
```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/models.dart';

class SupabaseDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<AuthResponse> signUp({required String email, required String password,
      required String name, String role = 'customer'}) async {
    return await _client.auth.signUp(email: email, password: password,
        data: {'name': name, 'role': role});
  }

  Future<AuthResponse> signIn({required String email, required String password}) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async => await _client.auth.signOut();

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<UserProfile?> getProfile(String userId) async {
    final data = await _client.from('profiles').select().eq('id', userId).maybeSingle();
    if (data == null) return null;
    return UserProfile.fromJson(data);
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _client.from('profiles').update(profile.toJson()).eq('id', profile.id);
  }

  Future<List<Category>> getCategories() async {
    final data = await _client.from('categories').select()
        .eq('is_active', true).order('sort_order');
    return (data as List).map((e) => Category.fromJson(e)).toList();
  }

  Future<List<Category>> getAllCategoriesAdmin() async {
    final data = await _client.from('categories').select().order('sort_order');
    return (data as List).map((e) => Category.fromJson(e)).toList();
  }

  Future<void> upsertCategory(Map<String, dynamic> data, {String? id}) async {
    if (id != null) {
      await _client.from('categories').update(data).eq('id', id);
    } else {
      await _client.from('categories').insert(data);
    }
  }

  Future<void> toggleCategoryActive(String id, bool isActive) async {
    await _client.from('categories').update({'is_active': isActive}).eq('id', id);
  }

  Future<List<Product>> getProducts({String? categoryId}) async {
    var query = _client.from('products').select().eq('is_available', true);
    if (categoryId != null) query = query.eq('category_id', categoryId);
    final data = await query.order('sort_order');
    return (data as List).map((e) => Product.fromJson(e)).toList();
  }

  Future<List<Product>> getAllProductsAdmin() async {
    final data = await _client.from('products').select().order('sort_order');
    return (data as List).map((e) => Product.fromJson(e)).toList();
  }

  Future<void> upsertProduct(Map<String, dynamic> data, {String? id}) async {
    if (id != null) {
      await _client.from('products').update(data).eq('id', id);
    } else {
      await _client.from('products').insert(data);
    }
  }

  Future<void> toggleProductAvailable(String id, bool isAvailable) async {
    await _client.from('products').update({'is_available': isAvailable}).eq('id', id);
  }

  Future<Order> createOrder({required String customerId, required String customerName,
      required String customerPhone, String? customerAddress, String? notes,
      required String paymentMethod, required double totalAmount,
      required List<CartItem> items}) async {
    final orderData = await _client.from('orders').insert({
      'customer_id': customerId, 'customer_name': customerName,
      'customer_phone': customerPhone, 'customer_address': customerAddress,
      'notes': notes, 'payment_method': paymentMethod,
      'total_amount': totalAmount, 'status': 'pending',
    }).select().single();

    final orderId = orderData['id'] as String;
    final orderItems = items.map((item) => {
      'order_id': orderId, 'product_id': item.product.id,
      'product_name': item.product.nameAr, 'product_price': item.product.price,
      'quantity': item.quantity, 'subtotal': item.subtotal,
    }).toList();

    await _client.from('order_items').insert(orderItems);
    return Order.fromJson({...orderData, 'order_items': []});
  }

  Future<List<Order>> getCustomerOrders(String customerId) async {
    final data = await _client.from('orders').select('*, order_items(*)')
        .eq('customer_id', customerId).order('created_at', ascending: false);
    return (data as List).map((e) => Order.fromJson(e)).toList();
  }

  Future<List<Order>> getAllOrdersAdmin() async {
    final data = await _client.from('orders').select('*, order_items(*)')
        .order('created_at', ascending: false);
    return (data as List).map((e) => Order.fromJson(e)).toList();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _client.from('orders').update({'status': status}).eq('id', orderId);
  }

  Stream<List<Map<String, dynamic>>> watchOrders() {
    return _client.from('orders').stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }
}
```

---

### FILE: lib/providers/app_providers.dart
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/datasources/remote/supabase_datasource.dart';
import '../data/models/models.dart';

final dataSourceProvider = Provider<SupabaseDataSource>((ref) => SupabaseDataSource());

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(dataSourceProvider).authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(data: (state) => state.session?.user, orElse: () => null);
});

final profileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(dataSourceProvider).getProfile(user.id);
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  return ref.watch(dataSourceProvider).getCategories();
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final productsProvider = FutureProvider.family<List<Product>, String?>((ref, categoryId) async {
  return ref.watch(dataSourceProvider).getProducts(categoryId: categoryId);
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      state = [...state.sublist(0, index),
        state[index].copyWith(quantity: state[index].quantity + 1),
        ...state.sublist(index + 1)];
    } else {
      state = [...state, CartItem(product: product, quantity: 1)];
    }
  }

  void removeItem(String productId) {
    final index = state.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (state[index].quantity > 1) {
        state = [...state.sublist(0, index),
          state[index].copyWith(quantity: state[index].quantity - 1),
          ...state.sublist(index + 1)];
      } else {
        state = state.where((item) => item.product.id != productId).toList();
      }
    }
  }

  void deleteItem(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void clearCart() => state = [];

  double get total => state.fold(0, (sum, item) => sum + item.subtotal);
  int get totalItems => state.fold(0, (sum, item) => sum + item.quantity);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) => CartNotifier());

final cartTotalProvider = Provider<double>((ref) => ref.watch(cartProvider.notifier).total);
final cartItemCountProvider = Provider<int>((ref) => ref.watch(cartProvider.notifier).totalItems);

final customerOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(dataSourceProvider).getCustomerOrders(user.id);
});

final adminOrdersProvider = StreamProvider<List<Order>>((ref) {
  final ds = ref.watch(dataSourceProvider);
  return ds.watchOrders().asyncMap((_) => ds.getAllOrdersAdmin());
});

final adminProductsProvider = FutureProvider<List<Product>>((ref) async {
  return ref.watch(dataSourceProvider).getAllProductsAdmin();
});

final adminCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  return ref.watch(dataSourceProvider).getAllCategoriesAdmin();
});
```

---

### FILE: lib/router/app_router.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/product/product_detail_screen.dart';
import '../presentation/screens/cart/cart_screen.dart';
import '../presentation/screens/checkout/checkout_screen.dart';
import '../presentation/screens/orders/orders_screen.dart';
import '../presentation/screens/orders/order_detail_screen.dart';
import '../presentation/screens/admin/admin_dashboard_screen.dart';
import '../presentation/screens/admin/admin_orders_screen.dart';
import '../presentation/screens/admin/admin_order_detail_screen.dart';
import '../presentation/screens/admin/admin_menu_screen.dart';
import '../presentation/screens/admin/admin_product_form_screen.dart';
import '../data/models/models.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.maybeWhen(
        data: (s) => s.session != null, orElse: () => false);
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isSplash = state.matchedLocation == '/splash';
      if (isSplash) return null;
      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
      GoRoute(path: '/product/:id', builder: (c, s) {
        final product = s.extra as Product;
        return ProductDetailScreen(product: product);
      }),
      GoRoute(path: '/cart', builder: (c, s) => const CartScreen()),
      GoRoute(path: '/checkout', builder: (c, s) => const CheckoutScreen()),
      GoRoute(path: '/orders', builder: (c, s) => const OrdersScreen()),
      GoRoute(path: '/orders/:id', builder: (c, s) {
        final order = s.extra as Order;
        return OrderDetailScreen(order: order);
      }),
      GoRoute(path: '/admin', builder: (c, s) => const AdminDashboardScreen()),
      GoRoute(path: '/admin/orders', builder: (c, s) => const AdminOrdersScreen()),
      GoRoute(path: '/admin/orders/:id', builder: (c, s) {
        final order = s.extra as Order;
        return AdminOrderDetailScreen(order: order);
      }),
      GoRoute(path: '/admin/menu', builder: (c, s) => const AdminMenuScreen()),
      GoRoute(path: '/admin/product/new', builder: (c, s) => const AdminProductFormScreen()),
      GoRoute(path: '/admin/product/edit', builder: (c, s) {
        final product = s.extra as Product?;
        return AdminProductFormScreen(product: product);
      }),
    ],
  );
});
```

---

### FILE: lib/main.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'app/theme/app_theme.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  runApp(const ProviderScope(child: Tarwi2aApp()));
}

class Tarwi2aApp extends ConsumerWidget {
  const Tarwi2aApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
    );
  }
}
```

---

### FILE: lib/presentation/widgets/category_chip.dart
```dart
import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({super.key, required this.label,
    required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider),
        ),
        child: Text(label, style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 13,
        )),
      ),
    );
  }
}
```

---

### FILE: lib/presentation/widgets/product_card.dart
```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../app/theme/app_theme.dart';
import '../../data/models/models.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const ProductCard({super.key, required this.product,
    required this.onTap, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: product.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (c, u) => Container(color: Colors.grey[100],
                          child: const Icon(Icons.fastfood, color: Colors.grey, size: 40)),
                        errorWidget: (c, u, e) => Container(color: Colors.grey[100],
                          child: const Icon(Icons.fastfood, color: Colors.grey, size: 40)),
                      )
                    : Container(color: Colors.grey[100],
                        child: const Center(child: Icon(Icons.fastfood, color: Colors.grey, size: 40))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.nameAr,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${product.price.toStringAsFixed(0)} ج',
                        style: const TextStyle(color: AppColors.primary,
                          fontWeight: FontWeight.w800, fontSize: 14)),
                      GestureDetector(
                        onTap: onAddToCart,
                        child: Container(
                          width: 30, height: 30,
                          decoration: const BoxDecoration(
                            color: AppColors.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.add, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### FILE: lib/presentation/screens/splash/splash_screen.dart
[PASTE EXACT CONTENT FROM THE ORIGINAL FILE PROVIDED - NO CHANGES]

### FILE: lib/presentation/screens/auth/login_screen.dart
[PASTE EXACT CONTENT FROM THE ORIGINAL FILE PROVIDED - NO CHANGES]

### FILE: lib/presentation/screens/auth/register_screen.dart
[PASTE EXACT CONTENT FROM THE ORIGINAL FILE PROVIDED - NO CHANGES]

### FILE: lib/presentation/screens/home/home_screen.dart
[PASTE EXACT CONTENT FROM THE ORIGINAL FILE PROVIDED - NO CHANGES]

### FILE: lib/presentation/screens/product/product_detail_screen.dart
[PASTE EXACT CONTENT FROM THE ORIGINAL FILE PROVIDED - NO CHANGES]

### FILE: lib/presentation/screens/cart/cart_screen.dart
[PASTE EXACT CONTENT FROM THE ORIGINAL FILE PROVIDED - NO CHANGES]

### FILE: lib/presentation/screens/checkout/checkout_screen.dart
[PASTE EXACT CONTENT FROM THE ORIGINAL FILE PROVIDED - NO CHANGES]

### FILE: lib/presentation/screens/orders/orders_screen.dart
[PASTE EXACT CONTENT FROM THE ORIGINAL FILE PROVIDED - NO CHANGES]

### FILE: lib/presentation/screens/orders/order_detail_screen.dart
[PASTE EXACT CONTENT FROM THE ORIGINAL FILE PROVIDED - NO CHANGES]

### FILE: lib/presentation/screens/admin/admin_dashboard_screen.dart
[PASTE EXACT CONTENT FROM THE ORIGINAL FILE PROVIDED - NO CHANGES]

### FILE: lib/presentation/screens/admin/admin_orders_screen.dart
[PASTE EXACT CONTENT FROM THE ORIGINAL FILE PROVIDED - NO CHANGES]

### FILE: lib/presentation/screens/admin/admin_order_detail_screen.dart
[PASTE EXACT CONTENT FROM THE ORIGINAL FILE PROVIDED - NO CHANGES]

---

### FILE: lib/presentation/screens/admin/admin_menu_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../data/models/models.dart';
import '../../../providers/app_providers.dart';

class AdminMenuScreen extends ConsumerWidget {
  const AdminMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(adminProductsProvider);
    final categories = ref.watch(adminCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المنيو'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => context.push('/admin/product/new'),
          ),
        ],
      ),
      body: products.when(
        data: (prods) => categories.when(
          data: (cats) {
            if (prods.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    const Text('مفيش أصناف لسه',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/admin/product/new'),
                      icon: const Icon(Icons.add),
                      label: const Text('أضف صنف جديد'),
                      style: ElevatedButton.styleFrom(minimumSize: const Size(180, 48)),
                    ),
                  ],
                ),
              );
            }

            // Group products by category
            final Map<String, List<Product>> grouped = {};
            final Map<String, String> catNames = {
              for (var c in cats) c.id: c.nameAr
            };
            grouped['no_category'] = [];
            for (var c in cats) grouped[c.id] = [];
            for (var p in prods) {
              final key = p.categoryId ?? 'no_category';
              grouped.putIfAbsent(key, () => []).add(p);
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: grouped.entries
                  .where((e) => e.value.isNotEmpty).length,
              itemBuilder: (context, index) {
                final entries = grouped.entries
                    .where((e) => e.value.isNotEmpty).toList();
                final entry = entries[index];
                final catName = entry.key == 'no_category'
                    ? 'بدون فئة'
                    : (catNames[entry.key] ?? 'فئة غير معروفة');

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(catName,
                        style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                    ),
                    ...entry.value.map((product) => _ProductAdminTile(
                      product: product,
                      onEdit: () => context.push('/admin/product/edit', extra: product),
                      onToggle: (val) async {
                        await ref.read(dataSourceProvider)
                            .toggleProductAvailable(product.id, val);
                        ref.invalidate(adminProductsProvider);
                      },
                    )),
                    const SizedBox(height: 8),
                  ],
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(child: Text('خطأ: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/product/new'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('صنف جديد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _ProductAdminTile extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final void Function(bool) onToggle;

  const _ProductAdminTile({required this.product, required this.onEdit, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        title: Text(product.nameAr,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: product.isAvailable ? AppColors.textPrimary : AppColors.textSecondary,
          )),
        subtitle: Text('${product.price.toStringAsFixed(0)} جنيه',
          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch.adaptive(
              value: product.isAvailable,
              activeColor: AppColors.primary,
              onChanged: onToggle,
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### FILE: lib/presentation/screens/admin/admin_product_form_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../data/models/models.dart';
import '../../../providers/app_providers.dart';

class AdminProductFormScreen extends ConsumerStatefulWidget {
  final Product? product;
  const AdminProductFormScreen({super.key, this.product});

  @override
  ConsumerState<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends ConsumerState<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameArController;
  late final TextEditingController _nameController;
  late final TextEditingController _descArController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageUrlController;
  String? _selectedCategoryId;
  bool _isAvailable = true;
  bool _isLoading = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameArController = TextEditingController(text: p?.nameAr ?? '');
    _nameController = TextEditingController(text: p?.name ?? '');
    _descArController = TextEditingController(text: p?.descriptionAr ?? '');
    _priceController = TextEditingController(text: p?.price.toStringAsFixed(0) ?? '');
    _imageUrlController = TextEditingController(text: p?.imageUrl ?? '');
    _selectedCategoryId = p?.categoryId;
    _isAvailable = p?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameController.dispose();
    _descArController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final data = {
        'name_ar': _nameArController.text.trim(),
        'name': _nameController.text.trim().isEmpty
            ? _nameArController.text.trim()
            : _nameController.text.trim(),
        'description_ar': _descArController.text.trim().isEmpty
            ? null : _descArController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'image_url': _imageUrlController.text.trim().isEmpty
            ? null : _imageUrlController.text.trim(),
        'category_id': _selectedCategoryId,
        'is_available': _isAvailable,
        'sort_order': 0,
      };

      await ref.read(dataSourceProvider).upsertProduct(
        data, id: _isEditing ? widget.product!.id : null);

      ref.invalidate(adminProductsProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'تم التعديل بنجاح ✓' : 'تم الإضافة بنجاح ✓'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حصل خطأ، حاول تاني'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(adminCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل الصنف' : 'صنف جديد'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name AR
            _buildLabel('اسم الصنف (عربي) *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameArController,
              decoration: const InputDecoration(hintText: 'مثال: شاورما دجاج'),
              validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),

            // Name EN
            _buildLabel('اسم الصنف (إنجليزي)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(hintText: 'Chicken Shawarma'),
            ),
            const SizedBox(height: 16),

            // Category
            _buildLabel('الفئة'),
            const SizedBox(height: 8),
            categories.maybeWhen(
              data: (cats) => DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: InputDecoration(
                  hintText: 'اختر فئة',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('بدون فئة')),
                  ...cats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nameAr))),
                ],
                onChanged: (v) => setState(() => _selectedCategoryId = v),
              ),
              orElse: () => const CircularProgressIndicator(),
            ),
            const SizedBox(height: 16),

            // Price
            _buildLabel('السعر (جنيه) *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              decoration: const InputDecoration(hintText: '0', suffixText: 'ج'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'أدخل السعر';
                if (double.tryParse(v) == null) return 'رقم غير صحيح';
                if (double.parse(v) <= 0) return 'السعر أكبر من صفر';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            _buildLabel('الوصف'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descArController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'وصف الصنف...'),
            ),
            const SizedBox(height: 16),

            // Image URL
            _buildLabel('رابط الصورة'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _imageUrlController,
              textDirection: TextDirection.ltr,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(hintText: 'https://...'),
            ),
            const SizedBox(height: 16),

            // Available toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('متاح للطلب', style: TextStyle(fontWeight: FontWeight.w600)),
                  Switch.adaptive(
                    value: _isAvailable,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _isAvailable = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(_isEditing ? 'حفظ التعديلات' : 'إضافة الصنف'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14));
  }
}
```

---

### FILE: supabase/schema.sql
```sql
-- Run this ENTIRE file in Supabase SQL Editor

CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  name TEXT NOT NULL DEFAULT '',
  phone TEXT,
  role TEXT NOT NULL DEFAULT 'customer' CHECK (role IN ('customer', 'admin')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  name_ar TEXT NOT NULL,
  image_url TEXT,
  sort_order INT DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  name_ar TEXT NOT NULL,
  description TEXT,
  description_ar TEXT,
  price DECIMAL(10,2) NOT NULL,
  image_url TEXT,
  is_available BOOLEAN DEFAULT true,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  customer_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  customer_name TEXT NOT NULL,
  customer_phone TEXT NOT NULL,
  customer_address TEXT,
  notes TEXT,
  payment_method TEXT NOT NULL CHECK (payment_method IN ('cash', 'wallet', 'instapay')),
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'confirmed', 'preparing', 'ready', 'delivered', 'cancelled')),
  total_amount DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE order_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  product_name TEXT NOT NULL,
  product_price DECIMAL(10,2) NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  subtotal DECIMAL(10,2) NOT NULL
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Admin can manage profiles" ON profiles FOR ALL USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));
CREATE POLICY "Anyone can view active categories" ON categories FOR SELECT USING (is_active = true);
CREATE POLICY "Admin can manage categories" ON categories FOR ALL USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));
CREATE POLICY "Anyone can view available products" ON products FOR SELECT USING (is_available = true);
CREATE POLICY "Admin can manage products" ON products FOR ALL USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));
CREATE POLICY "Customers can view own orders" ON orders FOR SELECT USING (customer_id = auth.uid());
CREATE POLICY "Customers can create orders" ON orders FOR INSERT WITH CHECK (customer_id = auth.uid());
CREATE POLICY "Admin can manage all orders" ON orders FOR ALL USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));
CREATE POLICY "Customers can view own order items" ON order_items FOR SELECT USING (EXISTS (SELECT 1 FROM orders WHERE id = order_id AND customer_id = auth.uid()));
CREATE POLICY "Customers can insert order items" ON order_items FOR INSERT WITH CHECK (EXISTS (SELECT 1 FROM orders WHERE id = order_id AND customer_id = auth.uid()));
CREATE POLICY "Admin can manage all order items" ON order_items FOR ALL USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE OR REPLACE FUNCTION handle_new_user() RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, name, role)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'name', ''), COALESCE(NEW.raw_user_meta_data->>'role', 'customer'));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION handle_new_user();

CREATE OR REPLACE FUNCTION update_updated_at() RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at();

INSERT INTO categories (name, name_ar, sort_order) VALUES
  ('Main Dishes', 'الأكلات الرئيسية', 1),
  ('Grills', 'مشويات', 2),
  ('Sandwiches', 'سندوتشات', 3),
  ('Drinks', 'مشروبات', 4),
  ('Desserts', 'حلويات', 5);

ALTER PUBLICATION supabase_realtime ADD TABLE orders;
```

---

## STEP 6 — Run these commands:
```bash
flutter pub get
flutter run
```

---

## STEP 7 — Setup first admin user:
After registering normally in the app, run this in Supabase SQL Editor:
```sql
UPDATE profiles SET role = 'admin' WHERE id = 'PASTE_YOUR_USER_UUID_HERE';
```
Get UUID from: Supabase Dashboard → Authentication → Users

---

## STEP 8 — Replace Supabase credentials:
Open lib/core/constants/app_constants.dart and replace:
- YOUR_SUPABASE_URL → your project URL from Supabase Dashboard → Settings → API
- YOUR_SUPABASE_ANON_KEY → your anon key from the same page

---

# DONE. DO NOT ADD ANYTHING ELSE.
