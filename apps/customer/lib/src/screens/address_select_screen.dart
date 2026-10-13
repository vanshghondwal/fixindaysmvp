/// Address selection step of the booking flow: saved addresses as radio
/// list, add-new, default handling.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'address_form_screen.dart';
import 'schedule_screen.dart';

class AddressSelectScreen extends StatefulWidget {
  final ProviderProfile provider;
  final List<BookingLineItem> items;
  final Totals totals;

  const AddressSelectScreen({
    super.key,
    required this.provider,
    required this.items,
    required this.totals,
  });

  @override
  State<AddressSelectScreen> createState() =>
      _AddressSelectScreenState();
}

class _AddressSelectScreenState
    extends State<AddressSelectScreen> {
  late Future<List<Address>> _future;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Address>> _load() async {
    final app = context.read<AppState>();
    final list =
        await app.repos.addresses.myAddresses(app.user!.id);
    if (_selectedId == null && list.isNotEmpty) {
      try {
        _selectedId =
            list.firstWhere((a) => a.isDefault).id;
      } catch (_) {
        _selectedId = list.first.id;
      }
    }
    return list;
  }

  Future<void> _select(String id) async {
    final app = context.read<AppState>();
    await app.repos.addresses.setDefault(app.user!.id, id);
    setState(() {
      _selectedId = id;
      _future = _load();
    });
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
                    onRetry: () =>
                        setState(() => _future = _load()),
                  );
                }
                final list = snap.data ?? [];
                if (list.isEmpty) {
                  return EmptyState(
                    icon: Icons.location_on_outlined,
                    title: 'No saved addresses',
                    message:
                        'Add an address so the provider knows where to come.',
                    actionLabel: t.t('addAddress'),
                    onAction: _addNew,
                  );
                }
                return RadioGroup<String>(
                  groupValue: _selectedId,
                  onChanged: (v) {
                    if (v != null) _select(v);
                  },
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.all(FxSpacing.md),
                    itemCount: list.length + 1,
                    itemBuilder: (_, i) {
                    if (i == list.length) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            top: 4),
                        child: FxButton(
                          label: t.t('addAddress'),
                          kind: FxButtonKind.outlined,
                          icon: Icons.add,
                          onPressed: _addNew,
                        ),
                      );
                    }
                    final a = list[i];
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: 12),
                      child: FxCard(
                        padding: EdgeInsets.zero,
                        child: RadioListTile<String>(
                          value: a.id,
                          title: Row(
                            children: [
                              Text(a.label,
                                  style: FxText.subtitle),
                              if (a.isDefault) ...[
                                const SizedBox(width: 8),
                                const Text('Default',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            FxColors.primary,
                                        fontWeight:
                                            FontWeight.w600)),
                              ],
                            ],
                          ),
                          subtitle: Text(a.short),
                          secondary: const Icon(
                              Icons.location_on_outlined),
                        ),
                      ),
                    );
                  },
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(FxSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: FxButton(
                  label: 'Continue',
                  onPressed: () async {
                    final list = await _future;
                    if (!mounted) return;
                    Address? selected;
                    try {
                      selected = list.firstWhere(
                          (a) => a.id == _selectedId);
                    } catch (_) {
                      selected = null;
                    }
                    // Copy to a final local so Dart promotes it to non-null
                    // (a mutable local captured in the route builder closure
                    // below does not promote reliably).
                    final address = selected;
                    if (address == null) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Please select an address')),
                      );
                      return;
                    }
                    if (!mounted) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ScheduleScreen(
                          provider: widget.provider,
                          items: widget.items,
                          totals: widget.totals,
                          address: address,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addNew() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
          builder: (_) => const AddressFormScreen()),
    );
    if (saved == true) {
      setState(() => _future = _load());
    }
  }
}
