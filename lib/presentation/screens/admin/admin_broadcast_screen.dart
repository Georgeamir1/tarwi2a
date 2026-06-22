import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../application/admin/admin_broadcast_cubit.dart';
import '../../../application/auth/auth_cubit.dart';
import '../../../domain/enums/broadcast_target.dart';
import '../../../domain/enums/notification_type.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_top_bar.dart';

class AdminBroadcastScreen extends StatefulWidget {
  const AdminBroadcastScreen({super.key});

  @override
  State<AdminBroadcastScreen> createState() => _AdminBroadcastScreenState();
}

class _AdminBroadcastScreenState extends State<AdminBroadcastScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  NotificationType _type = NotificationType.promotion;
  BroadcastTargetType _targetType = BroadcastTargetType.customers;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminBroadcastCubit>().previewRecipients(
            targetType: _targetType,
          );
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _onSendPressed() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthCubit>().state;
    if (auth is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لازم تكون مسجل دخول كإدارة')),
      );
      return;
    }
    setState(() => _sending = true);
    final ok = await context.read<AdminBroadcastCubit>().sendBroadcast(
          titleAr: _titleController.text,
          bodyAr: _bodyController.text,
          type: _type,
          targetType: _targetType,
          senderId: auth.profile.id,
        );
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) {
      _titleController.clear();
      _bodyController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال الإشعار بنجاح')),
      );
    }
  }

  void _onTargetTypeChanged(BroadcastTargetType? value) {
    if (value == null) return;
    setState(() => _targetType = value);
    context.read<AdminBroadcastCubit>().previewRecipients(targetType: value);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminBroadcastCubit, AdminBroadcastState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status &&
          curr.status == AdminBroadcastStatus.error,
      listener: (context, state) {
        if (state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.failure!.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppTopBar(
            title: 'إرسال إشعار',
            variant: TopBarVariant.withBack,
            actions: [
              IconButton(
                tooltip: 'سجل الإشعارات',
                icon: const Icon(Icons.history),
                onPressed: () => context.push(
                  '/admin/broadcast/history',
                  extra: context.read<AdminBroadcastCubit>(),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionLabel('نوع الإشعار'),
                  SegmentedButton<NotificationType>(
                    segments: const [
                      ButtonSegment(
                        value: NotificationType.promotion,
                        label: Text('عرض'),
                        icon: Icon(Icons.local_offer_outlined),
                      ),
                      ButtonSegment(
                        value: NotificationType.system,
                        label: Text('تنبيه'),
                        icon: Icon(Icons.info_outline),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: (sel) =>
                        setState(() => _type = sel.first),
                  ),
                  AppSpacing.gapH24,
                  AppTextField(
                    controller: _titleController,
                    label: 'العنوان',
                    hint: 'مثال: عرض جديد على المشويات',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'العنوان مطلوب'
                        : null,
                  ),
                  AppSpacing.gapH16,
                  AppTextField(
                    controller: _bodyController,
                    label: 'المحتوى',
                    hint: 'اكتب تفاصيل العرض أو التنبيه هنا',
                    maxLines: 4,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'المحتوى مطلوب'
                        : null,
                  ),
                  AppSpacing.gapH24,
                  _SectionLabel('المستهدفين'),
                  _TargetSelector(
                    value: _targetType,
                    onChanged: _onTargetTypeChanged,
                  ),
                  AppSpacing.gapH16,
                  if (state.previewRecipientsCount != null)
                    _RecipientCountPreview(
                        count: state.previewRecipientsCount!),
                  AppSpacing.gapH24,
                  AppButton(
                    label: _sending ? 'جاري الإرسال...' : 'إرسال الإشعار',
                    onPressed: _sending ? null : _onSendPressed,
                    icon: Icons.send,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _TargetSelector extends StatelessWidget {
  final BroadcastTargetType value;
  final ValueChanged<BroadcastTargetType> onChanged;
  const _TargetSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: BroadcastTargetType.values.map((t) {
        final selected = t == value;
        return ChoiceChip(
          label: Text(t.arabicLabel),
          selected: selected,
          onSelected: (_) => onChanged(t),
          avatar: Icon(_iconFor(t), size: 18),
        );
      }).toList(),
    );
  }

  IconData _iconFor(BroadcastTargetType t) {
    switch (t) {
      case BroadcastTargetType.all:
        return Icons.groups_outlined;
      case BroadcastTargetType.customers:
        return Icons.person_outline;
      case BroadcastTargetType.admins:
        return Icons.admin_panel_settings_outlined;
      case BroadcastTargetType.specific:
        return Icons.person_search_outlined;
    }
  }
}

class _RecipientCountPreview extends StatelessWidget {
  final int count;
  const _RecipientCountPreview({required this.count});

  String _formatCount(int count) {
    if (count == 0) return 'لن يتم الإرسال لأي مستخدم';
    if (count == 1) return 'سيتم الإرسال لمستخدم واحد';
    if (count == 2) return 'سيتم الإرسال لمستخدمين اثنين';
    if (count >= 3 && count <= 10) return 'سيتم الإرسال لـ $count مستخدمين';
    return 'سيتم الإرسال لـ $count مستخدم';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.people_outline, color: AppColors.primary),
          AppSpacing.gapW12,
          Expanded(
            child: Text(
              _formatCount(count),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
