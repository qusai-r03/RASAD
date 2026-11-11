import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';

class AppNotification {
  final String id, title, body, time;
  final bool read;
  const AppNotification({required this.id, required this.title, required this.body, required this.time, this.read = false});

  AppNotification asRead() => AppNotification(id: id, title: title, body: body, time: time, read: true);
}

/// ⚠️ إشعارات وهمية. تُستبدل بإشعارات FCM + مجموعة notifications في Firestore.
class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier()
      : super(const [
          AppNotification(
              id: 'n1', title: 'تم تحديث حالة شكواك #2025-0048', body: 'أصبحت قيد المعالجة.', time: 'قبل ساعتين'),
          AppNotification(
              id: 'n2',
              title: 'حفرة قريبة من مكان محفوظ',
              body: 'بالقرب من جامعة اليرموك، على بُعد 300 متر. أولوية عالية.',
              time: 'أمس'),
          AppNotification(
              id: 'n3', title: 'تم إنجاز شكواك #2025-0045', body: 'تم إصلاح الرصيف المكسور.', time: 'قبل 3 أيام', read: true),
        ]);

  void markRead(String id) => state = [for (final n in state) n.id == id ? n.asRead() : n];
  void markAllRead() => state = [for (final n in state) n.asRead()];
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) => NotificationsNotifier());

final unreadCountProvider = Provider<int>((ref) => ref.watch(notificationsProvider).where((n) => !n.read).length);

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(context.tr('notifications')),
        actions: [
          IconButton(
            tooltip: context.tr('markAllRead'),
            icon: const Icon(Icons.done_all_rounded),
            onPressed: () => ref.read(notificationsProvider.notifier).markAllRead(),
          ),
        ],
      ),
      body: list.isEmpty
          ? Center(child: Text(context.tr('noNotifications'), style: const TextStyle(color: AppColors.muted)))
          : ListView(padding: const EdgeInsets.all(16), children: [
              for (final n in list)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: AppDecor.card(radius: 14, color: n.read ? Colors.white : AppColors.primarySoft),
                  child: ListTile(
                    onTap: () => ref.read(notificationsProvider.notifier).markRead(n.id),
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.notifications_active_outlined, color: n.read ? AppColors.muted : AppColors.primary),
                    ),
                    title: Text(n.title, style: TextStyle(fontWeight: n.read ? FontWeight.w600 : FontWeight.w800, fontSize: 14.5)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('${n.body}\n${n.time}', style: const TextStyle(fontSize: 12.5, color: AppColors.muted, height: 1.4)),
                    ),
                    isThreeLine: true,
                  ),
                ),
            ]),
    );
  }
}
