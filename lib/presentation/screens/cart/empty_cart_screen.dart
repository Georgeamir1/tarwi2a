import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/empty_state.dart';

class EmptyCartScreen extends StatelessWidget {
  const EmptyCartScreen({super.key});

  @override
  Widget build(BuildContext context) {return Scaffold(
      appBar: const AppTopBar(title: 'السلة', variant: TopBarVariant.withBack),
      body: Center(
        child: EmptyState(
          icon: Icons.shopping_cart_outlined,
          title: 'السلة فاضية',
          subtitle: 'شوف القائمة واختار الأكلات اللي تعجبك',
          actionLabel: 'تصفح القائمة',
          onAction: () => context.go('/home'),
        ),
      ),
    );
  }
}
