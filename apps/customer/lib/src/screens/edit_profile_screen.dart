/// Edit profile: validated name + photo URL form → updateProfile.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _photoCtrl;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppState>().user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _photoCtrl =
        TextEditingController(text: user?.photoUrl ?? '');
  }

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
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Profile updated')),
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
      appBar: AppBar(title: Text(t.t('editProfile'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(FxSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: FxAvatar(
                      name: _nameCtrl.text, radius: 40),
                ),
                const SizedBox(height: 24),
                FxTextField(
                  controller: _nameCtrl,
                  label: 'Full name',
                  validator: (v) =>
                      validateRequired(v, 'Name'),
                ),
                const SizedBox(height: 16),
                FxTextField(
                  controller: _photoCtrl,
                  label: 'Photo URL (optional)',
                  hint: 'https://…',
                ),
                const SizedBox(height: 16),
                const Text('Phone', style: FxText.subtitle),
                const SizedBox(height: 6),
                Text(user?.phone ?? '—',
                    style: FxText.body.copyWith(
                        color: FxColors.secondaryText)),
                const SizedBox(height: 4),
                const Text(
                  'Phone and email are managed by auth — changes need '
                  'Firebase Auth config (see FIREBASE_SETUP.md).',
                  style: FxText.caption,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: const TextStyle(
                          color: FxColors.error)),
                ],
                const SizedBox(height: 24),
                FxButton(
                  label: FxLocalizations.of(context)
                      .t('save'),
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
