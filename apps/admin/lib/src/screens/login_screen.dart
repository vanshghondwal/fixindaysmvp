/// Admin sign-in gate: email login, custom-claim authorization check.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/admin_state.dart';
import 'admin_scaffold.dart';

class AdminLoginGate extends StatelessWidget {
  const AdminLoginGate({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AdminState>();
    switch (state.authState) {
      case AdminAuthState.demo:
      case AdminAuthState.authorized:
        return const AdminShell();
      case AdminAuthState.signedOut:
      case AdminAuthState.unauthorized:
      case AdminAuthState.unknown:
        return const LoginScreen();
    }
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController(text: 'admin@fixindays.demo');
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final state = context.read<AdminState>();
    final ok = await state.signIn(_email.text, _password.text);
    if (!mounted || ok) return;
    // Error is surfaced via state.error below.
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AdminState>();
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(FxSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.admin_panel_settings,
                      size: 64, color: FxColors.primary),
                  const SizedBox(height: FxSpacing.md),
                  const Text('FixinDays Admin',
                      style: FxText.headline, textAlign: TextAlign.center),
                  const SizedBox(height: FxSpacing.sm),
                  Text(
                    state.demoMode
                        ? 'Demo mode — sign in as admin@fixindays.demo with any password.'
                        : 'Sign in with an admin-authorized email. Authorization is verified from the Firebase Auth custom claim (admin: true).',
                    style: FxText.caption,
                    textAlign: TextAlign.center,
                  ),
                  if (state.demoMode) ...[
                    const SizedBox(height: FxSpacing.md),
                    const DemoBanner(),
                  ],
                  const SizedBox(height: FxSpacing.lg),
                  FxTextField(
                    controller: _email,
                    label: 'Email',
                    hint: 'admin@fixindays.demo',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: validateEmail,
                  ),
                  const SizedBox(height: FxSpacing.md),
                  FxTextField(
                    controller: _password,
                    label: 'Password',
                    obscure: true,
                    prefixIcon: const Icon(Icons.lock_outline),
                    validator: state.demoMode
                        ? null
                        : (v) => validatePassword(v),
                  ),
                  if (state.error != null) ...[
                    const SizedBox(height: FxSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(FxSpacing.sm),
                      decoration: BoxDecoration(
                        color: FxColors.error.withValues(alpha: 0.1),
                        borderRadius: const BorderRadius.circular(FxRadius.md),
                        border: Border.all(
                            color: FxColors.error.withValues(alpha: 0.4)),
                      ),
                      child: Text(state.error!, style: const TextStyle(
                          color: FxColors.error, fontSize: 13)),
                    ),
                  ],
                  const SizedBox(height: FxSpacing.lg),
                  FxButton(
                    label: 'Sign in',
                    loading: state.busy,
                    onPressed: state.busy ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
