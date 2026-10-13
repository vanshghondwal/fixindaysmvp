/// Platform settings editor: commission, support contacts, cash-on-service,
/// provider response timeout.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/admin_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commission = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _timeout = TextEditingController();
  bool _cashEnabled = true;
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _commission.dispose();
    _phone.dispose();
    _email.dispose();
    _timeout.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final state = context.read<AdminState>();
    setState(() => _saving = true);
    try {
      final settings = PlatformSettings(
        commissionBps: int.parse(_commission.text.trim()),
        supportPhone: _phone.text.trim(),
        supportEmail: _email.text.trim(),
        cashOnServiceEnabled: _cashEnabled,
        providerResponseTimeoutMin: int.parse(_timeout.text.trim()),
      );
      await state.repo.updatePlatformSettings(settings, state.adminId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Platform settings saved (audit entry written).')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return FutureBuilder<PlatformSettings>(
        future: context.read<AdminState>().repo.platformSettings(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const FxLoadingList(count: 5);
          }
          if (snap.hasError) {
            return ErrorPanel(
                message: '${snap.error}',
                onRetry: () => setState(() {}));
          }
          final s = snap.data!;
          _commission.text = '${s.commissionBps}';
          _phone.text = s.supportPhone;
          _email.text = s.supportEmail;
          _timeout.text = '${s.providerResponseTimeoutMin}';
          _cashEnabled = s.cashOnServiceEnabled;
          // Defer so we don't setState during build.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _loaded = true);
          });
          return const SizedBox.shrink();
        },
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(FxSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const FxSectionHeader(title: 'Platform settings'),
            const SizedBox(height: FxSpacing.md),
            FxTextField(
              controller: _commission,
              label: 'Commission (basis points)',
              hint: 'e.g. 1000 = 10%',
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse((v ?? '').trim());
                if (n == null || n < 0 || n > 10000) {
                  return 'Enter 0–10000';
                }
                return null;
              },
            ),
            const SizedBox(height: FxSpacing.md),
            FxTextField(
              controller: _phone,
              label: 'Support phone',
              keyboardType: TextInputType.phone,
              validator: (v) => validateRequired(v, 'Support phone'),
            ),
            const SizedBox(height: FxSpacing.md),
            FxTextField(
              controller: _email,
              label: 'Support email',
              keyboardType: TextInputType.emailAddress,
              validator: validateEmail,
            ),
            const SizedBox(height: FxSpacing.md),
            FxTextField(
              controller: _timeout,
              label: 'Provider response timeout (minutes)',
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse((v ?? '').trim());
                if (n == null || n <= 0) return 'Enter a positive number';
                return null;
              },
            ),
            const SizedBox(height: FxSpacing.md),
            FxCard(
              child: SwitchListTile(
                title: const Text('Cash on service enabled',
                    style: FxText.subtitle),
                subtitle: const Text(
                    'Allow customers to pay the provider in cash after service.',
                    style: FxText.caption),
                value: _cashEnabled,
                activeColor: FxColors.primary,
                onChanged: (v) => setState(() => _cashEnabled = v),
              ),
            ),
            const SizedBox(height: FxSpacing.lg),
            FxButton(
              label: 'Save settings',
              loading: _saving,
              icon: Icons.save_outlined,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
