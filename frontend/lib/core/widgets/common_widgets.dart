import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class ErrorDisplay extends StatelessWidget {
  const ErrorDisplay({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final String status;

  Color _colorForStatus(String s) {
    switch (s) {
      case 'OPEN':
        return Colors.blue;
      case 'ASSIGNED':
        return Colors.indigo;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'RESOLVED':
        return Colors.green;
      case 'CLOSED':
        return Colors.grey;
      case 'REOPENED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        status.replaceAll('_', ' '),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: _colorForStatus(status),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

class PriorityChip extends StatelessWidget {
  const PriorityChip({super.key, required this.priority});

  final String priority;

  Color _colorForPriority(String p) {
    switch (p) {
      case 'LOW':
        return Colors.teal;
      case 'MEDIUM':
        return Colors.amber.shade700;
      case 'HIGH':
        return Colors.deepOrange;
      case 'CRITICAL':
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        priority,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: _colorForPriority(priority),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
