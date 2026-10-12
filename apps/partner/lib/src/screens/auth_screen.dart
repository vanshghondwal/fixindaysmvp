/// Sign-in / registration: phone OTP and email tabs.
///
/// Demo mode: any 6-digit OTP is accepted (labelled in the UI). The role is
/// forced to [UserRole.provider] on sign-up — this app is provider-only.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/partner_state.dart';
import 'partner_gate.dart';

class AuthScreen extends StatefulWidget {
  final bool startOnRegister;

  const AuthScreen({super.key, this.startOnRegister = false});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Phone tab.
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _otpSent = false;
  String? _verificationId;
  bool _busy = false;

  // Email tab.
  bool _registerMode = false;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _registerMode = widget.startOnRegister;
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PartnerGate()),
      (_) => false,
    );
  }

  void _fail(Object e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sign-in failed: $e')),
    );
  }

  Future<void> _sendOtp() async {
    final err = validatePhone(_phoneCtrl.text);
    if (err != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    setState(() => _busy = true);
    try {
      final state = context.read<PartnerState>();
      _verificationId = await state.auth.sendPhoneOtp(_phoneCtrl.text.trim());
      setState(() => _otpSent = true);
    } catch (e) {
      _fail(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verifyOtp() async {
    final err = validateOtp(_otpCtrl.text);
    if (err != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    setState(() => _busy = true);
    try {
      final state = context.read<PartnerState>();
      await state.signInWithPhone(
          _verificationId ?? 'demo-partner-verification-id',
          _otpCtrl.text.trim());
      _goHome();
    } catch (e) {
      _fail(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final state = context.read<PartnerState>();
      if (_registerMode) {
        await state.signUpWithEmail(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
          _nameCtrl.text.trim(),
        );
      } else {
        await state.signInWithEmail(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
      }
      _goHome();
    } catch (e) {
      _fail(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FixinDays Partner'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Phone'), Tab(text: 'Email')],
          ),
        ),
        body: Column(
          children: [
            if (AppConfig.useDemoData) const DemoBanner(),
            Expanded(
              child: TabBarView(
                children: [
                  _phoneTab(),
                  _emailTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _phoneTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(FxSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline,
                  size: 16, color: FxColors.warning),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Demo mode: any 6-digit OTP works.',
                  style: FxText.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FxTextField(
            controller: _phoneCtrl,
            label: 'Phone number',
            hint: '+91 98765 43210',
            keyboardType: TextInputType.phone,
            validator: validatePhone,
          ),
          const SizedBox(height: 16),
          if (!_otpSent)
            FxButton(
              label: 'Send OTP',
              loading: _busy,
              onPressed: _busy ? null : _sendOtp,
            )
          else ...[
            FxTextField(
              controller: _otpCtrl,
              label: 'OTP',
              hint: '6-digit code',
              keyboardType: TextInputType.number,
              validator: validateOtp,
            ),
            const SizedBox(height: 16),
            FxButton(
              label: 'Verify & continue',
              loading: _busy,
              onPressed: _busy ? null : _verifyOtp,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _busy
                  ? null
                  : () => setState(() => _otpSent = false),
              child: const Text('Change phone number'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _emailTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(FxSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Sign in')),
                ButtonSegment(value: true, label: Text('Register')),
              ],
              selected: {_registerMode},
              onSelectionChanged: (s) =>
                  setState(() => _registerMode = s.first),
            ),
            const SizedBox(height: 16),
            if (_registerMode) ...[
              FxTextField(
                controller: _nameCtrl,
                label: 'Full name',
                hint: 'Your name',
                validator: (v) => validateRequired(v, 'Name'),
              ),
              const SizedBox(height: 16),
            ],
            FxTextField(
              controller: _emailCtrl,
              label: 'Email',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: validateEmail,
            ),
            const SizedBox(height: 16),
            FxTextField(
              controller: _passwordCtrl,
              label: 'Password',
              hint: 'Minimum 6 characters',
              obscure: true,
              validator: validatePassword,
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.info_outline,
                    size: 16, color: FxColors.warning),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Partner accounts are always created with the provider role.',
                    style: FxText.caption,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FxButton(
              label: _registerMode ? 'Register' : 'Sign in',
              loading: _busy,
              onPressed: _busy ? null : _submitEmail,
            ),
          ],
        ),
      ),
    );
  }
}
