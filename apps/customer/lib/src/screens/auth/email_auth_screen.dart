/// Email authentication: login / signup tabs + password reset.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import 'auth_flow.dart';

class EmailAuthScreen extends StatelessWidget {
  const EmailAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.t('emailSignIn')),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Log in'),
              Tab(text: 'Sign up'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _LoginForm(),
            _SignupForm(),
          ],
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await context.read<AppState>().repos.auth.signInWithEmail(
            _emailCtrl.text.trim(),
            _passCtrl.text,
          );
      if (!mounted) return;
      await completeSignIn(context, user);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _forgotPassword() async {
    final emailCtrl = TextEditingController();
    final t = FxLocalizations.of(context);
    final app = context.read<AppState>();
    final sent = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.t('resetPassword')),
        content: FxTextField(
          controller: emailCtrl,
          label: 'Email',
          hint: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          validator: validateEmail,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FxButton(
            label: 'Send link',
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    if (sent != true) return;
    final emailError = validateEmail(emailCtrl.text.trim());
    if (emailError != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(emailError)),
      );
      return;
    }
    await app.repos.auth.sendPasswordReset(emailCtrl.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'If an account exists, a reset link was sent. '
          '(Demo mode: no email is actually sent.)',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(FxSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FxTextField(
              controller: _emailCtrl,
              label: 'Email',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: validateEmail,
            ),
            const SizedBox(height: 16),
            FxTextField(
              controller: _passCtrl,
              label: 'Password',
              obscure: _obscure,
              validator: validatePassword,
              suffixIcon: IconButton(
                icon: Icon(
                    _obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () =>
                    setState(() => _obscure = !_obscure),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: const TextStyle(color: FxColors.error)),
            ],
            const SizedBox(height: 24),
            FxButton(
              label: 'Log in',
              loading: _loading,
              onPressed: _loading ? null : _login,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _forgotPassword,
              child: const Text('Forgot password?'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignupForm extends StatefulWidget {
  const _SignupForm();

  @override
  State<_SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<_SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await context.read<AppState>().repos.auth.signUpWithEmail(
            _emailCtrl.text.trim(),
            _passCtrl.text,
            _nameCtrl.text.trim(),
            UserRole.customer,
          );
      if (!mounted) return;
      await completeSignIn(context, user);
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(FxSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FxTextField(
              controller: _nameCtrl,
              label: 'Full name',
              hint: 'Aarav Mehta',
              validator: (v) => validateRequired(v, 'Name'),
            ),
            const SizedBox(height: 16),
            FxTextField(
              controller: _emailCtrl,
              label: 'Email',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: validateEmail,
            ),
            const SizedBox(height: 16),
            FxTextField(
              controller: _passCtrl,
              label: 'Password',
              hint: 'Minimum 6 characters',
              obscure: _obscure,
              validator: validatePassword,
              suffixIcon: IconButton(
                icon: Icon(
                    _obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () =>
                    setState(() => _obscure = !_obscure),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: const TextStyle(color: FxColors.error)),
            ],
            const SizedBox(height: 24),
            FxButton(
              label: 'Create account',
              loading: _loading,
              onPressed: _loading ? null : _signup,
            ),
          ],
        ),
      ),
    );
  }
}
