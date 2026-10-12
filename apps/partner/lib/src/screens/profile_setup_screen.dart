/// Business profile setup (new partners) / edit (existing partners).
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/delhi_localities.dart';
import '../state/partner_state.dart';
import 'partner_gate.dart';

class ProfileSetupScreen extends StatefulWidget {
  final ProviderProfile? existing;

  const ProfileSetupScreen({super.key, this.existing});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _businessCtrl;
  late final TextEditingController _ownerCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _expCtrl;
  late final TextEditingController _descCtrl;
  late Set<String> _areas;
  bool _saving = false;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _businessCtrl = TextEditingController(text: e?.businessName ?? '');
    _ownerCtrl = TextEditingController(text: e?.ownerName ?? '');
    _phoneCtrl = TextEditingController(text: e?.phone ?? '');
    _expCtrl = TextEditingController(
        text: e == null ? '' : e.experienceYears.toString());
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _areas = Set<String>.from(e?.serviceAreas ?? const []);
  }

  @override
  void dispose() {
    _businessCtrl.dispose();
    _ownerCtrl.dispose();
    _phoneCtrl.dispose();
    _expCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
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
      final user = state.user!;
      final existing = widget.existing;
      final profile = ProviderProfile(
        id: user.id,
        businessName: _businessCtrl.text.trim(),
        ownerName: _ownerCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        photoUrl: existing?.photoUrl,
        description: _descCtrl.text.trim(),
        experienceYears: int.parse(_expCtrl.text.trim()),
        serviceAreas: _areas.toList(),
        verificationStatus:
            existing?.verificationStatus ?? VerificationStatus.notApplied,
        ratingAvg: existing?.ratingAvg ?? 0,
        ratingCount: existing?.ratingCount ?? 0,
        active: existing?.active ?? true,
        createdAt: existing?.createdAt ?? DateTime.now().toUtc(),
      );
      await state.ops.updateProfile(profile);
      await state.refreshPartnerData();
      if (!mounted) return;
      if (_editing) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PartnerGate()),
          (_) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _validateExp(String? v) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null || n < 0 || n > 60) {
      return 'Enter years of experience (0–60)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Edit profile' : 'Set up your business'),
      ),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(FxSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_editing) ...[
                      const Text(
                        'Tell customers about your business. '
                        'You can change this later.',
                        style: FxText.body,
                      ),
                      const SizedBox(height: 16),
                    ],
                    FxTextField(
                      controller: _businessCtrl,
                      label: 'Business name',
                      hint: 'e.g. Sharma Home Services',
                      validator: (v) =>
                          validateRequired(v, 'Business name'),
                    ),
                    const SizedBox(height: 16),
                    FxTextField(
                      controller: _ownerCtrl,
                      label: 'Owner name',
                      hint: 'Your full name',
                      validator: (v) =>
                          validateRequired(v, 'Owner name'),
                    ),
                    const SizedBox(height: 16),
                    FxTextField(
                      controller: _phoneCtrl,
                      label: 'Business phone',
                      hint: '+91 98765 43210',
                      keyboardType: TextInputType.phone,
                      validator: validatePhone,
                    ),
                    const SizedBox(height: 16),
                    FxTextField(
                      controller: _expCtrl,
                      label: 'Years of experience',
                      hint: 'e.g. 5',
                      keyboardType: TextInputType.number,
                      validator: _validateExp,
                    ),
                    const SizedBox(height: 16),
                    FxTextField(
                      controller: _descCtrl,
                      label: 'About your business',
                      hint: 'What services do you specialise in?',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    const Text('Service areas', style: FxText.subtitle),
                    const SizedBox(height: 8),
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
          ),
        ],
      ),
    );
  }
}
