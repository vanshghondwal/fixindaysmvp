/// Service areas: multi-select chips saved to the provider profile.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/delhi_localities.dart';
import '../state/partner_state.dart';

class AreasScreen extends StatefulWidget {
  const AreasScreen({super.key});

  @override
  State<AreasScreen> createState() => _AreasScreenState();
}

class _AreasScreenState extends State<AreasScreen> {
  late Set<String> _areas;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _areas = Set<String>.from(
        context.read<PartnerState>().profile?.serviceAreas ?? const []);
  }

  Future<void> _save() async {
    if (_areas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Select at least one service area.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final state = context.read<PartnerState>();
      final p = state.profile!;
      await state.ops.updateProfile(
          p.copyWith(serviceAreas: _areas.toList()));
      await state.refreshPartnerData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service areas updated.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Service areas')),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(FxSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Choose the localities where you accept bookings. '
                    'Customers outside these areas will not see your profile.',
                    style: FxText.body,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: delhiLocalities.map((a) {
                      final selected = _areas.contains(a);
                      return FilterChip(
                        label: Text(a),
                        selected: selected,
                        onSelected: (_) => setState(() {
                          if (selected) {
                            _areas.remove(a);
                          } else {
                            _areas.add(a);
                          }
                        }),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  FxButton(
                    label: t.t('save'),
                    loading: _saving,
                    onPressed: _saving ? null : _save,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
