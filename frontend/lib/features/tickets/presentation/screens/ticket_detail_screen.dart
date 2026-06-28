import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../domain/models/ticket_model.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  const TicketDetailScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  final _commentController = TextEditingController();
  bool _submittingComment = false;

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;
    setState(() => _submittingComment = true);
    try {
      await ref
          .read(ticketRepositoryProvider)
          .addComment(widget.ticketId, _commentController.text.trim());
      _commentController.clear();
      ref.invalidate(ticketDetailProvider(widget.ticketId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      setState(() => _submittingComment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketAsync = ref.watch(ticketDetailProvider(widget.ticketId));
    final user = ref.watch(authProvider).user;
    final canChangeStatus = user?.isAgent == true || user?.isAdmin == true;

    return Scaffold(
      appBar: AppBar(title: const Text('Ticket Details')),
      body: ticketAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorDisplay(
          message: e.toString(),
          onRetry: () => ref.invalidate(ticketDetailProvider(widget.ticketId)),
        ),
        data: (data) {
          final ticket = data as TicketModel;
          return ResponsiveLayout(
            child: SingleChildScrollView(
              padding: Responsive.pagePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        ticket.ticketNumber,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const Spacer(),
                      StatusChip(status: ticket.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  PriorityChip(priority: ticket.priority),
                  const Divider(height: 32),
                  _InfoRow('District', ticket.district?.name ?? '-'),
                  _InfoRow('Tehsil', ticket.tehsil?.name ?? '-'),
                  _InfoRow('Project', ticket.project?.name ?? '-'),
                  _InfoRow(
                    'Created',
                    DateFormat('dd MMM yyyy, hh:mm a').format(ticket.createdAt),
                  ),
                  const SizedBox(height: 16),
                  Text('Remarks', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(ticket.remarks),
                  if (ticket.attachments.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Attachments', style: Theme.of(context).textTheme.titleMedium),
                    ...ticket.attachments.map((a) => ListTile(
                          leading: const Icon(Icons.attachment),
                          title: Text(a.fileName),
                          subtitle: Text('${(a.fileSize / 1024).toStringAsFixed(1)} KB'),
                          onTap: () {
                            // TODO: Open attachment URL in browser/viewer
                          },
                        )),
                  ],
                  if (canChangeStatus) ...[
                    const SizedBox(height: 16),
                    _StatusUpdateBar(ticketId: ticket.id, currentStatus: ticket.status),
                  ],
                  const Divider(height: 32),
                  Text('Comments', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...ticket.comments.map((c) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(c.userName ?? 'User'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.message),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd MMM yyyy, hh:mm a').format(c.createdAt),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      labelText: 'Add a comment',
                      suffixIcon: IconButton(
                        icon: _submittingComment
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send),
                        onPressed: _submittingComment ? null : _addComment,
                      ),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _StatusUpdateBar extends ConsumerStatefulWidget {
  const _StatusUpdateBar({required this.ticketId, required this.currentStatus});
  final String ticketId;
  final String currentStatus;

  @override
  ConsumerState<_StatusUpdateBar> createState() => _StatusUpdateBarState();
}

class _StatusUpdateBarState extends ConsumerState<_StatusUpdateBar> {
  late String _status;
  bool _loading = false;

  static const _statuses = [
    'OPEN', 'ASSIGNED', 'IN_PROGRESS', 'RESOLVED', 'CLOSED', 'REOPENED',
  ];

  @override
  void initState() {
    super.initState();
    _status = widget.currentStatus;
  }

  Future<void> _update() async {
    setState(() => _loading = true);
    try {
      await ref.read(ticketRepositoryProvider).updateStatus(widget.ticketId, _status);
      ref.invalidate(ticketDetailProvider(widget.ticketId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Update Status'),
                items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _status = v!),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _loading ? null : _update,
              child: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
