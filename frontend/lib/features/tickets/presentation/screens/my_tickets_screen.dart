import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../domain/models/ticket_model.dart';

class MyTicketsScreen extends ConsumerWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(ticketsProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tickets'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: ticketsAsync.when(
        loading: () => const LoadingWidget(message: 'Loading tickets...'),
        error: (e, _) => ErrorDisplay(
          message: e.toString(),
          onRetry: () => ref.invalidate(ticketsProvider(null)),
        ),
        data: (tickets) {
          final list = tickets.cast<TicketModel>();
          if (list.isEmpty) {
            return const Center(child: Text('No tickets found. Create your first complaint!'));
          }
          return ResponsiveLayout(
            child: ListView.builder(
              padding: Responsive.pagePadding(context),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final ticket = list[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(ticket.ticketNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ticket.remarks, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd MMM yyyy, hh:mm a').format(ticket.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    trailing: StatusChip(status: ticket.status),
                    onTap: () => context.push('/tickets/${ticket.id}'),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tickets/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
