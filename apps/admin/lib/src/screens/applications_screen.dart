/// Provider verification queue: review [ProviderApplication]s, inspect the
/// uploaded documents (storage paths — downloads need Firebase Storage
/// configured in the console), then approve or reject with an admin note.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/admin_state.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  late Future<List<ProviderApplication>> _future;

  @override
  void initState() {
    super.initState();
    _reload(initial: true);
  }

  void _reload({bool initial = false}) {
    final f = context.read<AdminState>().repo.pendingApplications();
    if (initial) {
      _future = f;
    } else {
      setState(() => _future = f);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProviderApplication>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const FxLoadingList(count: 4);
        }
        if (snap.hasError) {
          return ErrorPanel(
              message: '${snap.error}', onRetry: () => _reload());
        }
        final apps = snap.data!;
        if (apps.isEmpty) {
          return EmptyState(
            icon: Icons.verified_outlined,
            title: 'No pending applications',
            message: 'New provider verification requests will appear here.',
            actionLabel: 'Refresh',
            onAction: () => _reload(),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView.separated(
            padding: const EdgeInsets.all(FxSpacing.lg),
            itemCount: apps.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: FxSpacing.md),
            itemBuilder: (context, i) =>
                _applicationCard(context, apps[i]),
          ),
        );
      },
    );
  }

  Widget _applicationCard(BuildContext context, ProviderApplication app) {
    return FxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FxAvatar(name: app.providerId, radius: 20),
              const SizedBox(width: FxSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Provider ${app.providerId}',
                        style: FxText.subtitle),
                    Text(
                      'Submitted ${_fmtDate(app.submittedAt)} · '
                      '${app.status.name}',
                      style: FxText.caption,
                    ),
                  ],
                ),
              ),
              StatusChip(
                label: app.status.name.toUpperCase(),
                color: app.status == VerificationStatus.pending
                    ? FxColors.warning
                    : FxColors.navy,
              ),
            ],
          ),
          if (app.adminNote != null) ...[
            const SizedBox(height: FxSpacing.sm),
            Text('Note: ${app.adminNote}', style: FxText.caption),
          ],
          const SizedBox(height: FxSpacing.md),
          FxButton(
            label: 'Review application',
            kind: FxButtonKind.outlined,
            icon: Icons.visibility_outlined,
            onPressed: () => _reviewDialog(context, app),
          ),
        ],
      ),
    );
  }

  Future<void> _reviewDialog(
      BuildContext context, ProviderApplication app) async {
    final note = TextEditingController();
    final decided = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Review application'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Uploaded documents (storage paths):',
                  style: FxText.subtitle),
              const SizedBox(height: FxSpacing.sm),
              if (app.documents.isEmpty)
                const Text('No documents uploaded.', style: FxText.caption)
              else
                for (final e in app.documents.entries)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: FxSpacing.xs),
                    child: Row(
                      children: [
                        const Icon(Icons.insert_drive_file_outlined,
                            size: 16, color: FxColors.secondaryText),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text('${e.key}: ${e.value}',
                              style: FxText.caption),
                        ),
                      ],
                    ),
                  ),
              const SizedBox(height: FxSpacing.sm),
              const Text(
                'Note: downloading these files needs Firebase Storage '
                'configured and the verification-docs/ rules deployed '
                '(admin read only). See FIREBASE_SETUP.md.',
                style: FxText.caption,
              ),
              const SizedBox(height: FxSpacing.md),
              FxTextField(
                controller: note,
                label: 'Admin note',
                hint: 'Reason (shown to provider)',
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FxButton(
            label: 'Reject',
            kind: FxButtonKind.destructive,
            onPressed: () {
              Navigator.pop(ctx, false);
            },
          ),
          FxButton(
            label: 'Approve',
            onPressed: () {
              Navigator.pop(ctx, true);
            },
          ),
        ],
      ),
    );
    if (decided == null || !mounted) return;
    final state = context.read<AdminState>();
    try {
      await state.repo.reviewApplication(
          app.id, decided, note.text.trim(), state.adminId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Application ${decided ? 'approved' : 'rejected'} — audit entry written.')));
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
