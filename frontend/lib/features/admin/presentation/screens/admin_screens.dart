import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../tickets/domain/models/ticket_model.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: ResponsiveLayout(
        child: SingleChildScrollView(
          padding: Responsive.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Administration', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              analyticsAsync.when(
                loading: () => const LoadingWidget(),
                error: (e, _) => ErrorDisplay(message: e.toString()),
                data: (data) {
                  final analytics = data as TicketAnalytics;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _StatCard('Total Tickets', analytics.total.toString(), Colors.blue),
                      ...analytics.byStatus.entries.map(
                        (e) => _StatCard(e.key, e.value.toString(), Colors.teal),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              Text('Management', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: Responsive.isMobile(context) ? 2 : 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _AdminCard(Icons.map, 'Districts', () => context.push('/admin/districts')),
                  _AdminCard(Icons.location_city, 'Tehsils', () => context.push('/admin/tehsils')),
                  _AdminCard(Icons.work, 'Projects', () => context.push('/admin/projects')),
                  _AdminCard(Icons.assignment_ind, 'Assign Tickets', () => context.push('/admin/assign')),
                  _AdminCard(Icons.bar_chart, 'Reports', () => context.push('/admin/reports')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label.replaceAll('_', ' ')),
          ],
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard(this.icon, this.title, this.onTap);
  final IconData icon;
  final String title;
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
              Icon(icon, size: 40, color: const Color(0xFF1565C0)),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class DistrictManagementScreen extends ConsumerStatefulWidget {
  const DistrictManagementScreen({super.key});

  @override
  ConsumerState<DistrictManagementScreen> createState() => _DistrictManagementScreenState();
}

class _DistrictManagementScreenState extends ConsumerState<DistrictManagementScreen> {
  final _nameController = TextEditingController();

  Future<void> _add() async {
    if (_nameController.text.isEmpty) return;
    await ref.read(ticketRepositoryProvider).createDistrict(_nameController.text);
    _nameController.clear();
    ref.invalidate(districtsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final districtsAsync = ref.watch(districtsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('District Management')),
      body: ResponsiveLayout(
        child: Column(
          children: [
            Padding(
              padding: Responsive.pagePadding(context),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'District Name'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _add, child: const Text('Add')),
                ],
              ),
            ),
            Expanded(
              child: districtsAsync.when(
                loading: () => const LoadingWidget(),
                error: (e, _) => ErrorDisplay(message: e.toString()),
                data: (districts) {
                  final list = districts.cast<DistrictModel>();
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) => ListTile(
                      leading: const Icon(Icons.map),
                      title: Text(list[i].name),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

class TehsilManagementScreen extends ConsumerStatefulWidget {
  const TehsilManagementScreen({super.key});

  @override
  ConsumerState<TehsilManagementScreen> createState() => _TehsilManagementScreenState();
}

class _TehsilManagementScreenState extends ConsumerState<TehsilManagementScreen> {
  final _nameController = TextEditingController();
  DistrictModel? _selectedDistrict;

  Future<void> _add() async {
    if (_selectedDistrict == null || _nameController.text.isEmpty) return;
    await ref.read(ticketRepositoryProvider).createTehsil(_selectedDistrict!.id, _nameController.text);
    _nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final districtsAsync = ref.watch(districtsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tehsil Management')),
      body: ResponsiveLayout(
        child: districtsAsync.when(
          loading: () => const LoadingWidget(),
          error: (e, _) => ErrorDisplay(message: e.toString()),
          data: (districts) {
            final list = districts.cast<DistrictModel>();
            return Padding(
              padding: Responsive.pagePadding(context),
              child: Column(
                children: [
                  DropdownButtonFormField<DistrictModel>(
                    decoration: const InputDecoration(labelText: 'Select District'),
                    value: _selectedDistrict,
                    items: list.map((d) => DropdownMenuItem(value: d, child: Text(d.name))).toList(),
                    onChanged: (d) => setState(() => _selectedDistrict = d),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Tehsil Name'))),
                      const SizedBox(width: 8),
                      ElevatedButton(onPressed: _add, child: const Text('Add')),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

class ProjectManagementScreen extends ConsumerStatefulWidget {
  const ProjectManagementScreen({super.key});

  @override
  ConsumerState<ProjectManagementScreen> createState() => _ProjectManagementScreenState();
}

class _ProjectManagementScreenState extends ConsumerState<ProjectManagementScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  DistrictModel? _district;
  TehsilModel? _tehsil;
  List<TehsilModel> _tehsils = [];

  Future<void> _add() async {
    if (_tehsil == null || _nameController.text.isEmpty) return;
    await ref.read(ticketRepositoryProvider).createProject(
          _tehsil!.id,
          _nameController.text,
          _descController.text.isEmpty ? null : _descController.text,
        );
    _nameController.clear();
    _descController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final districtsAsync = ref.watch(districtsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Project Management')),
      body: ResponsiveLayout(
        child: districtsAsync.when(
          loading: () => const LoadingWidget(),
          error: (e, _) => ErrorDisplay(message: e.toString()),
          data: (districts) {
            final list = districts.cast<DistrictModel>();
            return Padding(
              padding: Responsive.pagePadding(context),
              child: Column(
                children: [
                  DropdownButtonFormField<DistrictModel>(
                    decoration: const InputDecoration(labelText: 'District'),
                    value: _district,
                    items: list.map((d) => DropdownMenuItem(value: d, child: Text(d.name))).toList(),
                    onChanged: (d) async {
                      setState(() {
                        _district = d;
                        _tehsil = null;
                      });
                      if (d != null) {
                        final tehsils = await ref.read(ticketRepositoryProvider).getTehsils(d.id);
                        setState(() => _tehsils = tehsils);
                      }
                    },
                  ),
                  DropdownButtonFormField<TehsilModel>(
                    decoration: const InputDecoration(labelText: 'Tehsil'),
                    value: _tehsil,
                    items: _tehsils.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                    onChanged: (t) => setState(() => _tehsil = t),
                  ),
                  TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Project Name')),
                  TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Description')),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: _add, child: const Text('Add Project')),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }
}

class TicketAssignmentScreen extends ConsumerWidget {
  const TicketAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(ticketsProvider('OPEN'));

    return Scaffold(
      appBar: AppBar(title: const Text('Ticket Assignment')),
      body: ticketsAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorDisplay(message: e.toString()),
        data: (tickets) {
          final list = tickets.cast<TicketModel>();
          if (list.isEmpty) {
            return const Center(child: Text('No unassigned/open tickets'));
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final ticket = list[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(ticket.ticketNumber),
                  subtitle: Text(ticket.remarks, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    icon: const Icon(Icons.assignment_ind),
                    onPressed: () => _showAssignDialog(context, ref, ticket),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAssignDialog(BuildContext context, WidgetRef ref, TicketModel ticket) {
    final agentIdController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Assign ${ticket.ticketNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter Support Agent User ID'),
            // TODO: Replace text input with agent dropdown once agent listing API is defined
            TextField(
              controller: agentIdController,
              decoration: const InputDecoration(labelText: 'Agent ID (UUID)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(ticketRepositoryProvider).assignTicket(ticket.id, agentIdController.text);
                ref.invalidate(ticketsProvider('OPEN'));
                if (context.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }
}

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: analyticsAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorDisplay(message: e.toString()),
        data: (data) {
          final analytics = data as TicketAnalytics;
          return Padding(
            padding: Responsive.pagePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Tickets: ${analytics.total}', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 24),
                Text('By Status', style: Theme.of(context).textTheme.titleLarge),
                ...analytics.byStatus.entries.map((e) => ListTile(
                      title: Text(e.key.replaceAll('_', ' ')),
                      trailing: Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    )),
                const SizedBox(height: 16),
                Text('By Priority', style: Theme.of(context).textTheme.titleLarge),
                ...analytics.byPriority.entries.map((e) => ListTile(
                      title: Text(e.key),
                      trailing: Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}
