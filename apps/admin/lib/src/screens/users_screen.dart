/// User management: search users, restrict/unrestrict accounts.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/admin_state.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _search = TextEditingController();
  late Future<List<AppUser>> _future;

  @override
  void initState() {
    super.initState();
    _reload(initial: true);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reload({bool initial = false}) {
    final f =
        context.read<AdminState>().repo.searchUsers(_search.text);
    if (initial) {
      _future = f;
    } else {
      setState(() => _future = f);
    }
  }

  Future<void> _toggleRestrict(BuildContext context, AppUser u) async {
    final confirm = await fxConfirm(
      context,
      title: 'Restrict user?',
      message:
          '${u.name} (${u.phone}) will be blocked from the platform until unrestricted. Logged in the audit trail.',
      confirmLabel: 'Restrict',
      destructive: true,
    );
    if (!confirm || !mounted) return;
    final state = context.read<AdminState>();
    try {
      await state.repo.restrictUser(u.id, true, state.adminId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${u.name} restricted (audit entry written).')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              FxSpacing.lg, FxSpacing.lg, FxSpacing.lg, 0),
          child: FxTextField(
            controller: _search,
            label: 'Search users',
            hint: 'Name, phone or email…',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _search.clear();
                _reload();
              },
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<AppUser>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const FxLoadingList(count: 5);
              }
              if (snap.hasError) {
                return ErrorPanel(
                    message: '${snap.error}', onRetry: () => _reload());
              }
              final users = snap.data!;
              if (users.isEmpty) {
                return EmptyState(
                  icon: Icons.people_outline,
                  title: 'No users found',
                  message: 'Try a different search term.',
                  actionLabel: 'Refresh',
                  onAction: () => _reload(),
                );
              }
              return RefreshIndicator(
                onRefresh: () async => _reload(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(FxSpacing.lg),
                  itemCount: users.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: FxSpacing.sm),
                  itemBuilder: (context, i) =>
                      _userRow(context, users[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _userRow(BuildContext context, AppUser u) {
    return FxCard(
      child: Row(
        children: [
          FxAvatar(name: u.name, radius: 20),
          const SizedBox(width: FxSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u.name, style: FxText.subtitle),
                Text(
                    '${u.phone}${u.email != null ? ' · ${u.email}' : ''}',
                    style: FxText.caption),
              ],
            ),
          ),
          StatusChip(
            label: u.role.name.toUpperCase(),
            color: u.role == UserRole.provider
                ? FxColors.navy
                : FxColors.primary,
          ),
          const SizedBox(width: FxSpacing.sm),
          IconButton(
            tooltip: 'Restrict user',
            icon: const Icon(Icons.block_outlined,
                color: FxColors.error),
            onPressed: () => _toggleRestrict(context, u),
          ),
        ],
      ),
    );
  }
}
