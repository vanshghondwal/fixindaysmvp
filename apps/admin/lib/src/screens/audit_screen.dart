/// Admin audit trail: every moderation/settings action with actor + target.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/admin_state.dart';

class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key});

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  late Future<List<AdminAuditLog>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<AdminState>().repo.auditLog(limit: 100);
  }

  void _reload() {
    setState(() {
      _future = context.read<AdminState>().repo.auditLog(limit: 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AdminAuditLog>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const FxLoadingList(count: 6);
        }
        if (snap.hasError) {
          return ErrorPanel(
              message: '${snap.error}', onRetry: _reload);
        }
        final logs = snap.data!;
        if (logs.isEmpty) {
          return EmptyState(
            icon: Icons.history_outlined,
            title: 'No audit entries',
            message: 'Admin actions will be recorded here.',
            actionLabel: 'Refresh',
            onAction: _reload,
          );
        }
        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView.separated(
            padding: const EdgeInsets.all(FxSpacing.lg),
            itemCount: logs.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: FxSpacing.sm),
            itemBuilder: (context, i) => _logRow(logs[i]),
          ),
        );
      },
    );
  }

  Widget _logRow(AdminAuditLog log) {
    return FxCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(FxSpacing.sm),
            decoration: BoxDecoration(
              color: FxColors.navy.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.circular(FxRadius.md),
            ),
            child:
                const Icon(Icons.history, size: 18, color: FxColors.navy),
          ),
          const SizedBox(width: FxSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.action, style: FxText.subtitle),
                Text(
                  '${log.targetType} ${log.targetId} · by ${log.adminId}',
                  style: FxText.caption,
                ),
                if (log.details.isNotEmpty)
                  Text(log.details, style: FxText.caption),
              ],
            ),
          ),
          Text(_fmtDateTime(log.createdAt), style: FxText.caption),
        ],
      ),
    );
  }

  String _fmtDateTime(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
