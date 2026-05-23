import 'package:flutter/material.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/empty_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {return const Scaffold(
      appBar: AppTopBar(title: 'الإشعارات', variant: TopBarVariant.withBack),
      body: Center(
        child: EmptyState(
          icon: Icons.notifications_none_outlined,
          title: 'مفيش إشعارات',
          subtitle: 'هتلاقي هنا كل التحديثات الجديدة',
        ),
      ),
    );
  }
}
