import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/empty_state.dart';

class EmptyCartScreen extends StatelessWidget {
  const EmptyCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(
        title: '\u0627\u0644\u0633\u0644\u0629',
        variant: TopBarVariant.withBack,
      ),
      body: Center(
        child: EmptyState(
          icon: Icons.shopping_cart_outlined,
          title:
              '\u0627\u0644\u0633\u0644\u0629 \u0641\u0627\u0636\u064a\u0629',
          subtitle:
              '\u0634\u0648\u0641 \u0627\u0644\u0642\u0627\u0626\u0645\u0629 \u0648\u0627\u062e\u062a\u0627\u0631 \u0627\u0644\u0623\u0643\u0644\u0627\u062a \u0627\u0644\u0644\u064a \u062a\u0639\u062c\u0628\u0643',
          actionLabel:
              '\u062a\u0635\u0641\u062d \u0627\u0644\u0642\u0627\u0626\u0645\u0629',
          onAction: () => context.go('/home'),
        ),
      ),
    );
  }
}
