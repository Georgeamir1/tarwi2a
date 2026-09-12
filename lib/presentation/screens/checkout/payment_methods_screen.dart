import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/app_button.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String _selected = 'cash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(
          title: 'وسيلة الدفع', variant: TopBarVariant.withBack),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                RadioGroup<String>(
                  groupValue: _selected,
                  onChanged: (v) {
                    if (v != null) setState(() => _selected = v);
                  },
                  child: const Column(
                    children: [
                      _PaymentOption(
                        icon: Icons.money_outlined,
                        title: 'كاش عند الاستلام',
                        subtitle: 'ادفع لما تستلم الطلب',
                        value: 'cash',
                      ),
                      SizedBox(height: 12),
                      _PaymentOption(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'المحفظة الإلكترونية',
                        subtitle: 'ادفع من رصيد محفظتك',
                        value: 'wallet',
                      ),
                      SizedBox(height: 12),
                      _PaymentOption(
                        icon: Icons.qr_code_outlined,
                        title: 'انستا باي',
                        subtitle: 'ادفع عن طريق InstaPay',
                        value: 'instapay',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: AppButton(
              label: 'تأكيد',
              onPressed: () => context.pop(_selected),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;

  const _PaymentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: const BorderSide(color: AppColors.outlineVariant),
      ),
      child: RadioListTile<String>(
        value: value,
        activeColor: AppColors.primary,
        toggleable: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
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
