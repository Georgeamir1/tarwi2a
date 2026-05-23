import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../../app/theme/app_theme.dart';
import '../../widgets/app_top_bar.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  List<Printer> _printers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _discoverPrinters();
  }

  Future<void> _discoverPrinters() async {
    setState(() => _isLoading = true);
    try {
      final printers = await Printing.listPrinters();
      setState(() => _printers = printers);
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(
        title: 'إعدادات الطابعة',
        variant: TopBarVariant.withBack,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.print,
                              color: AppColors.primary, size: 24),
                          AppSpacing.gapW12,
                          Text(
                            'الطابعات المتصلة',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      AppSpacing.gapH16,
                      if (_printers.isEmpty)
                        Text(
                          'لا توجد طابعات متصلة. تأكد من توصيل الطابعة عبر Bluetooth أو USB.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ..._printers.map(
                        (printer) => ListTile(
                          leading:
                              const Icon(Icons.print, color: AppColors.primary),
                          title: Text(printer.name),
                          subtitle: Text(printer.url),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.sm)),
                          tileColor: AppColors.surfaceContainerHighest,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md),
                        ),
                      ),
                      AppSpacing.gapH16,
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _discoverPrinters,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('بحث عن طابعات'),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapH24,
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'معلومات',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      AppSpacing.gapH12,
                      Text(
                        '• تدعم الطابعات الحرارية عبر Bluetooth أو USB\n'
                        '• حجم الورقة الافتراضي: 80mm\n'
                        '• لطباعة طلب، افتح تفاصيل الطلب واضغط على زر الطباعة\n'
                        '• تأكد من تشغيل Bluetooth قبل محاولة الطباعة',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
