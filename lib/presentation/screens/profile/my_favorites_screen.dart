import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/empty_state.dart';

class MyFavoritesScreen extends StatelessWidget {
  const MyFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {return Scaffold(
      appBar: const AppTopBar(title: 'المفضلة', variant: TopBarVariant.withBack),
      body: Center(
        child: EmptyState(
          icon: Icons.favorite_outline,
          title: 'مفيش مفضلات لسه',
          subtitle: 'اعمل قلب على الأكلات اللي بتحبها',
          actionLabel: 'تصفح القائمة',
          onAction: () => context.go('/home'),
        ),
      ),
    );
  }
}
