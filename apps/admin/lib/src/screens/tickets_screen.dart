/// Support ticket queue: view open/in-progress tickets and update status.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/admin_state.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  late Future<List<SupportTicket>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<AdminState>().repo.openTickets();
  }

  void _reload() {
    setState(() {
      _future = context.read<AdminState>().repo.openTickets();
    });
  }

  Color _statusColor(TicketStatus s) => switch (s) {
        TicketStatus.open => FxColors.warning,
        TicketStatus.inProgress => FxColors.navy,
        TicketStatus.resolved => FxColors.primary,
        TicketStatus.closed => FxColors.secondaryText,
      };

  Future<void> _changeStatus(
      BuildContext context, SupportTicket t) async {
    TicketStatus? next;
    await showDialog<void>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Update ticket status'),
        children: [
          for (final s in TicketStatus.values)
            SimpleDialogOption(
              onPressed: () {
                next = s;
                Navigator.pop(ctx);
              },
              child: Row(
                children: [
                  Icon(Icons.circle, size: 10, color: _statusColor(s)),
                  const SizedBox(width: 8),
                  Text(s.name),
                ],
              ),
            ),
        ],
      ),
    );
    if (next == null || next == t.status || !mounted) return;
    final state = context.read<AdminState>();
    try {
      await state.repo.updateTicketStatus(t.id, next!, state.adminId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket updated.')));
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SupportTicket>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const FxLoadingList(count: 4);
        }
        if (snap.hasError) {
          return ErrorPanel(
              message: '${snap.error}', onRetry: _reload);
        }
        final tickets = snap.data!;
        if (tickets.isEmpty) {
          return EmptyState(
            icon: Icons.support_agent_outlined,
            title: 'No open tickets',
            message: 'Support requests from customers and providers appear here.',
            actionLabel: 'Refresh',
            onAction: _reload,
          );
        }
        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView.separated(
            padding: const EdgeInsets.all(FxSpacing.lg),
            itemCount: tickets.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: FxSpacing.md),
            itemBuilder: (context, i) => _ticketCard(context, tickets[i]),
          ),
        );
      },
    );
  }

  Widget _ticketCard(BuildContext context, SupportTicket t) {
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(t.category.toUpperCase(),
                    style: FxText.subtitle),
              ),
              StatusChip(label: t.status.name.toUpperCase(), color: _statusColor(t.status)),
            ],
          ),
          const SizedBox(height: FxSpacing.sm),
          Text(t.description, style: FxText.body),
          const SizedBox(height: FxSpacing.sm),
          Text(
            'By ${t.userId} (${t.userRole.name})'
            '${t.bookingId != null ? ' · booking ${t.bookingId}' : ''}',
            style: FxText.caption,
          ),
          if (t.evidenceUrls.isNotEmpty)
            Text('${t.evidenceUrls.length} attachment(s)',
                style: FxText.caption),
          const SizedBox(height: FxSpacing.md),
          FxButton(
            label: 'Update status',
            kind: FxButtonKind.outlined,
            icon: Icons.edit_outlined,
            onPressed: () => _changeStatus(context, t),
          ),
        ],
      ),
    );
  }
}
