/// Profile setup for new users: name + optional photo URL.
///
/// Phone is shown read-only (it comes from auth). Email changes are disabled
/// honestly — they need Firebase Auth profile config (see FIREBASE_SETUP.md).
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'location_screen.dart';
import 'root_shell.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _photoCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _photoCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final app = context.read<AppState>();
      final photo = _photoCtrl.text.trim();
      await app.repos.auth.updateProfile(
        name: _nameCtrl.text.trim(),
        photoUrl: photo.isEmpty ? null : photo,
      );
      app.setUser(app.repos.auth.currentUser);
      final addresses =
          await app.repos.addresses.myAddresses(app.user!.id);
      if (!mounted) return;
      final next = addresses.isEmpty
          ? const LocationScreen()
          : const RootShell();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => next),
        (_) => false,
      );
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
    final t = FxLocalizations.of(context);
    final user = context.watch<AppState>().user;
    return Scaffold(
      appBar: AppBar(title: Text(t.t('setupProfile'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(FxSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Tell us about yourself', style: FxText.headline),
                const SizedBox(height: 8),
                Text(
                  'Providers see your name when you book.',
                  style: FxText.body
                      .copyWith(color: FxColors.secondaryText),
                ),
                const SizedBox(height: 24),
                FxTextField(
                  controller: _nameCtrl,
                  label: 'Full name',
                  hint: 'Aarav Mehta',
                  validator: (v) => validateRequired(v, 'Name'),
                ),
                const SizedBox(height: 16),
                FxTextField(
                  controller: _photoCtrl,
                  label: 'Photo URL (optional)',
                  hint: 'https://…',
                ),
                const SizedBox(height: 16),
                _readonlyRow('Phone', user?.phone ?? '—'),
                const SizedBox(height: 12),
                _readonlyRow('Email', user?.email ?? '—',
                    note:
                        'Email changes need Firebase Auth profile config — '
                        'see FIREBASE_SETUP.md.'),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: const TextStyle(color: FxColors.error)),
                ],
                const SizedBox(height: 24),
                FxButton(
                  label: 'Save & continue',
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

  Widget _readonlyRow(String label, String value, {String? note}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: FxText.subtitle),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: FxColors.background,
            border: Border.all(color: FxColors.borders),
            borderRadius: const BorderRadius.circular(FxRadius.md),
          ),
          child: Text(value.isEmpty ? '—' : value,
              style: FxText.body
                  .copyWith(color: FxColors.secondaryText)),
        ),
        if (note != null) ...[
          const SizedBox(height: 4),
          Text(note, style: FxText.caption),
        ],
      ],
    );
  }
}
