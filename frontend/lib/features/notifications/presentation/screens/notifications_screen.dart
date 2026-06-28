import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../tickets/domain/models/ticket_model.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(notificationRepositoryProvider).markAllAsRead();
              ref.invalidate(notificationsProvider);
            },
            child: const Text('Mark all read', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorDisplay(
          message: e.toString(),
          onRetry: () => ref.invalidate(notificationsProvider),
        ),
        data: (notifications) {
          final list = notifications.cast<NotificationModel>();
          if (list.isEmpty) {
            return const Center(child: Text('No notifications'));
          }
          return ResponsiveLayout(
            child: ListView.builder(
              padding: Responsive.pagePadding(context),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final n = list[index];
                return Card(
                  color: n.isRead ? null : Colors.blue.shade50,
                  child: ListTile(
                    leading: Icon(
                      n.isRead ? Icons.notifications_none : Icons.notifications_active,
                      color: n.isRead ? Colors.grey : Colors.blue,
                    ),
                    title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.body),
                        Text(
                          DateFormat('dd MMM yyyy, hh:mm a').format(n.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    onTap: () async {
                      if (!n.isRead) {
                        await ref.read(notificationRepositoryProvider).markAsRead(n.id);
                        ref.invalidate(notificationsProvider);
                      }
                      if (n.ticketId != null && context.mounted) {
                        context.push('/tickets/${n.ticketId}');
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ResponsiveLayout(
        child: Padding(
          padding: Responsive.pagePadding(context),
          child: Column(
            children: [
              const CircleAvatar(radius: 48, child: Icon(Icons.person, size: 48)),
              const SizedBox(height: 16),
              Text(user?.fullName ?? '', style: Theme.of(context).textTheme.headlineSmall),
              Text(user?.email ?? ''),
              const SizedBox(height: 32),
              Card(
                child: Column(
                  children: [
                    ListTile(title: const Text('Mobile'), trailing: Text(user?.mobileNumber ?? '')),
                    const Divider(height: 1),
                    ListTile(title: const Text('Role'), trailing: Text(user?.role ?? '')),
                    const Divider(height: 1),
                    ListTile(title: const Text('Gender'), trailing: Text(user?.gender ?? '')),
                    if (user?.aadhaarNumber != null) ...[
                      const Divider(height: 1),
                      ListTile(title: const Text('Aadhaar'), trailing: Text('****${user!.aadhaarNumber!.substring(8)}')),
                    ],
                    if (user?.passportNumber != null) ...[
                      const Divider(height: 1),
                      ListTile(title: const Text('Passport'), trailing: Text(user!.passportNumber!)),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/login');
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Logout', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
