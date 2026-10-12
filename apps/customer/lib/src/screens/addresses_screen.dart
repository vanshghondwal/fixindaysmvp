/// Saved addresses: list, add, edit, delete, set default.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'address_form_screen.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() =>
      _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  late Future<List<Address>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Address>> _load() {
    final app = context.read<AppState>();
    return app.repos.addresses.myAddresses(app.user!.id);
  }

  void _refresh() => setState(() => _future = _load());

  Future<void> _delete(Address a) async {
    final ok = await fxConfirm(
      context,
      title: 'Delete address?',
      message: '“${a.label}” will be removed from your saved addresses.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok) return;
    await context
        .read<AppState>()
        .repos
        .addresses
        .deleteAddress(a.id);
    _refresh();
  }

  Future<void> _setDefault(Address a) async {
    final app = context.read<AppState>();
    await app.repos.addresses.setDefault(app.user!.id, a.id);
    _refresh();
  }

  Future<void> _openForm({Address? existing}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            AddressFormScreen(existing: existing),
      ),
    );
    if (saved == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.t('address'))),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Expanded(
            child: FutureBuilder<List<Address>>(
              future: _future,
              builder: (_, snap) {
                if (snap.connectionState ==
                    ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(FxSpacing.md),
                    child: FxLoadingList(),
                  );
                }
                if (snap.hasError) {
                  return ErrorPanel(
                    message: snap.error.toString(),
                    onRetry: _refresh,
                  );
                }
                final list = snap.data ?? [];
                if (list.isEmpty) {
                  return EmptyState(
                    icon: Icons.location_on_outlined,
                    title: 'No saved addresses',
                    message:
                        'Add one so providers know where to come.',
                    actionLabel: t.t('addAddress'),
                    onAction: () => _openForm(),
                  );
                }
                return ListView.builder(
                  padding:
                      const EdgeInsets.all(FxSpacing.md),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final a = list[i];
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: 12),
                      child: FxCard(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(a.label,
                                      style: FxText.subtitle),
                                ),
                                if (a.isDefault)
                                  const Text('Default',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color:
                                              FxColors.primary,
                                          fontWeight:
                                              FontWeight
                                                  .w600)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(a.short,
                                style: FxText.body),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (!a.isDefault)
                                  TextButton(
                                    onPressed: () =>
                                        _setDefault(a),
                                    child: const Text(
                                        'Set default'),
                                  ),
                                TextButton(
                                  onPressed: () => _openForm(
                                      existing: a),
                                  child:
                                      const Text('Edit'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      _delete(a),
                                  child: const Text('Delete',
                                      style: TextStyle(
                                          color: FxColors
                                              .error)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
