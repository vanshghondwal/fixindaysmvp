/// Add / edit a service: name, category, description, price basis, price,
/// unit and duration. Saves via [ProviderOpsRepository.upsertService].
///
/// Note shown in the UI: existing bookings keep their historical prices —
/// price changes apply to new bookings only.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/partner_state.dart';

/// Hardcoded demo categories (labelled as such in the UI).
const List<Map<String, String>> _demoCategories = [
  {'id': 'plumbing', 'name': 'Plumbing'},
  {'id': 'electrical', 'name': 'Electrical'},
  {'id': 'cleaning', 'name': 'Cleaning'},
  {'id': 'appliance', 'name': 'Appliance Repair'},
  {'id': 'painting', 'name': 'Painting'},
  {'id': 'carpentry', 'name': 'Carpentry'},
];

class ServiceEditScreen extends StatefulWidget {
  final ProviderService? service;

  const ServiceEditScreen({super.key, this.service});

  @override
  State<ServiceEditScreen> createState() => _ServiceEditScreenState();
}

class _ServiceEditScreenState extends State<ServiceEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _unitCtrl;
  late final TextEditingController _durationCtrl;
  late String _categoryId;
  late PriceBasis _priceBasis;
  late bool _active;
  bool _saving = false;

  bool get _editing => widget.service != null;

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _descCtrl = TextEditingController(text: s?.description ?? '');
    _priceCtrl = TextEditingController(
        text: s == null ? '' : (s.pricePaise ~/ 100).toString());
    _unitCtrl = TextEditingController(text: s?.unit ?? 'visit');
    _durationCtrl = TextEditingController(
        text: s?.durationMin?.toString() ?? '');
    _categoryId = s?.categoryId ?? _demoCategories.first['id']!;
    _priceBasis = s?.priceBasis ?? PriceBasis.fixed;
    _active = s?.active ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _unitCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  String? _validateDuration(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return null;
    final n = int.tryParse(t);
    if (n == null || n <= 0 || n > 1440) {
      return 'Enter minutes (1–1440) or leave blank';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final state = context.read<PartnerState>();
      final existing = widget.service;
      final priceText = _priceCtrl.text.trim();
      final pricePaise =
          priceText.isEmpty ? 0 : int.parse(priceText) * 100;
      final durationText = _durationCtrl.text.trim();
      final service = ProviderService(
        id: existing?.id ?? '',
        providerId: state.user!.id,
        categoryId: _categoryId,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        priceBasis: _priceBasis,
        pricePaise: pricePaise,
        unit: _unitCtrl.text.trim().isEmpty
            ? 'visit'
            : _unitCtrl.text.trim(),
        durationMin:
            durationText.isEmpty ? null : int.parse(durationText),
        active: _active,
      );
      await state.ops.upsertService(service);
      if (!mounted) return;
      Navigator.of(context).pop(true);
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
      appBar:
          AppBar(title: Text(_editing ? 'Edit service' : 'Add service')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(FxSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FxTextField(
                      controller: _nameCtrl,
                      label: 'Service name',
                      hint: 'e.g. Tap & Mixer Repair',
                      validator: (v) =>
                          validateRequired(v, 'Service name'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Category (demo list)',
                        style: FxText.subtitle),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _categoryId,
                      decoration: const InputDecoration(
                        hintText: 'Choose a category',
                      ),
                      items: _demoCategories
                          .map((c) => DropdownMenuItem<String>(
                                value: c['id']!,
                                child: Text(c['name']!),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _categoryId = v!),
                    ),
                    const SizedBox(height: 16),
                    FxTextField(
                      controller: _descCtrl,
                      label: 'Description',
                      hint: 'What is included?',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    const Text('Price basis', style: FxText.subtitle),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<PriceBasis>(
                      initialValue: _priceBasis,
                      items: const [
                        DropdownMenuItem(
                            value: PriceBasis.fixed,
                            child: Text('Fixed price')),
                        DropdownMenuItem(
                            value: PriceBasis.estimate,
                            child: Text('Estimate (starting price)')),
                        DropdownMenuItem(
                            value: PriceBasis.quote,
                            child: Text('Quote (price on inspection)')),
                      ],
                      onChanged: (v) =>
                          setState(() => _priceBasis = v!),
                    ),
                    const SizedBox(height: 16),
                    FxTextField(
                      controller: _priceCtrl,
                      label: _priceBasis == PriceBasis.quote
                          ? 'Starting price (₹, optional for quote)'
                          : 'Price (₹)',
                      hint: 'e.g. 299',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.currency_rupee),
                      validator: _priceBasis == PriceBasis.quote
                          ? (v) => (v ?? '').trim().isEmpty
                              ? null
                              : validatePrice(v)
                          : validatePrice,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FxTextField(
                            controller: _unitCtrl,
                            label: 'Unit',
                            hint: 'visit / hour / room',
                            validator: (v) =>
                                validateRequired(v, 'Unit'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FxTextField(
                            controller: _durationCtrl,
                            label: 'Duration (min)',
                            hint: 'Optional',
                            keyboardType: TextInputType.number,
                            validator: _validateDuration,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      value: _active,
                      onChanged: (v) =>
                          setState(() => _active = v),
                      title: const Text('Visible to customers',
                          style: FxText.subtitle),
                      subtitle: const Text(
                          'Turn off to pause new bookings for this service.',
                          style: FxText.caption),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 16,
                            color: FxColors.secondaryText),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Existing bookings keep their historical prices — '
                            'price changes apply to new bookings only.',
                            style: FxText.caption,
                          ),
                        ),
                      ],
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
