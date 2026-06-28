import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/utils/responsive.dart';

class CitizenDashboardScreen extends ConsumerWidget {
  const CitizenDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: ResponsiveLayout(
        child: Padding(
          padding: Responsive.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${user?.fullName ?? 'Citizen'}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text('Manage your complaints and track their status'),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.count(
                  crossAxisCount: Responsive.isMobile(context) ? 2 : 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _DashboardCard(
                      icon: Icons.add_circle,
                      title: 'Create Ticket',
                      color: Colors.blue,
                      onTap: () => context.push('/tickets/create'),
                    ),
                    _DashboardCard(
                      icon: Icons.list_alt,
                      title: 'My Tickets',
                      color: Colors.teal,
                      onTap: () => context.push('/tickets'),
                    ),
                    _DashboardCard(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      color: Colors.orange,
                      onTap: () => context.push('/notifications'),
                    ),
                    _DashboardCard(
                      icon: Icons.person,
                      title: 'Profile',
                      color: Colors.purple,
                      onTap: () => context.push('/profile'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tickets/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Complaint'),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
