/// Shared address add/edit form used by onboarding, address selection and
/// the addresses screen.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

const _labels = ['Home', 'Work', 'Other'];

class AddressFormScreen extends StatefulWidget {
  final Address? existing;

  const AddressFormScreen({super.key, this.existing});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _line1Ctrl;
  late final TextEditingController _line2Ctrl;
  late final TextEditingController _landmarkCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _pincodeCtrl;
  String _label = 'Home';
  bool _setDefault = true;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _line1Ctrl = TextEditingController(text: e?.line1 ?? '');
    _line2Ctrl = TextEditingController(text: e?.line2 ?? '');
    _landmarkCtrl = TextEditingController(text: e?.landmark ?? '');
    _cityCtrl = TextEditingController(text: e?.city ?? '');
    _pincodeCtrl = TextEditingController(text: e?.pincode ?? '');
    _label = e?.label ?? 'Home';
    _setDefault = e?.isDefault ?? true;
  }

  @override
  void dispose() {
    _line1Ctrl.dispose();
    _line2Ctrl.dispose();
    _landmarkCtrl.dispose();
    _cityCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final app = context.read<AppState>();
    final user = app.user;
    if (user == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final id = widget.existing?.id ??
          'addr-${DateTime.now().millisecondsSinceEpoch}';
      final address = Address(
        id: id,
        userId: user.id,
        label: _label,
        line1: _line1Ctrl.text.trim(),
        line2:
            _line2Ctrl.text.trim().isEmpty ? null : _line2Ctrl.text.trim(),
        landmark: _landmarkCtrl.text.trim().isEmpty
            ? null
            : _landmarkCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        pincode: _pincodeCtrl.text.trim(),
        isDefault: _setDefault,
      );
      await app.repos.addresses.saveAddress(address);
      if (_setDefault) {
        await app.repos.addresses.setDefault(user.id, id);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
          title: Text(isEdit ? 'Edit address' : 'Add address')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(FxSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Label', style: FxText.subtitle),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _label,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: FxColors.white,
                  ),
                  items: _labels
                      .map((l) => DropdownMenuItem(
                          value: l, child: Text(l)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _label = v ?? 'Home'),
                ),
                const SizedBox(height: 16),
                FxTextField(
                  controller: _line1Ctrl,
                  label: 'Address line 1',
                  hint: 'Flat / house no., street',
                  validator: (v) =>
                      validateRequired(v, 'Address'),
                ),
                const SizedBox(height: 16),
                FxTextField(
                  controller: _line2Ctrl,
                  label: 'Address line 2 (optional)',
                  hint: 'Area, sector',
                ),
                const SizedBox(height: 16),
                FxTextField(
                  controller: _landmarkCtrl,
                  label: 'Landmark (optional)',
                  hint: 'Near…',
                ),
                const SizedBox(height: 16),
                FxTextField(
                  controller: _cityCtrl,
                  label: 'City',
                  hint: 'Delhi',
                  validator: (v) =>
                      validateRequired(v, 'City'),
                ),
                const SizedBox(height: 16),
                FxTextField(
                  controller: _pincodeCtrl,
                  label: 'Pincode',
                  hint: '110053',
                  keyboardType: TextInputType.number,
                  validator: validatePincode,
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  value: _setDefault,
                  onChanged: (v) =>
                      setState(() => _setDefault = v ?? false),
                  title: const Text('Set as default address'),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity:
                      ListTileControlAffinity.leading,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!,
                      style:
                          const TextStyle(color: FxColors.error)),
                ],
                const SizedBox(height: 16),
                FxButton(
                  label: isEdit ? 'Save changes' : 'Save address',
                  loading: _loading,
                  onPressed: _loading ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
