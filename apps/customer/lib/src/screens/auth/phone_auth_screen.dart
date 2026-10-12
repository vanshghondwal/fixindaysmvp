/// Phone authentication: number entry → OTP → verify.
///
/// In demo mode any 6-digit OTP works — this is labelled clearly in the UI.
library;

import 'dart:async';

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import 'auth_flow.dart';

const _countryCodes = ['+91', '+1', '+44', '+61', '+971'];

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneCtrl = TextEditingController();
  String _countryCode = '+91';
  bool _otpStep = false;
  bool _loading = false;
  String? _error;
  String? _verificationId;

  final _otpCtrls =
      List.generate(6, (_) => TextEditingController());
  final _otpNodes = List.generate(6, (_) => FocusNode());
  int _secondsLeft = 0;
  Timer? _timer;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    for (final c in _otpCtrls) {
      c.dispose();
    }
    for (final n in _otpNodes) {
      n.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _fullPhone => '$_countryCode${_phoneCtrl.text.trim()}';

  Future<void> _sendOtp() async {
    final phoneError = validatePhone(_fullPhone);
    if (phoneError != null) {
      setState(() => _error = phoneError);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final id =
          await context.read<AppState>().repos.auth.sendPhoneOtp(_fullPhone);
      if (!mounted) return;
      setState(() {
        _verificationId = id;
        _otpStep = true;
        _loading = false;
      });
      _startTimer();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  String get _otp => _otpCtrls.map((c) => c.text).join();

  Future<void> _verify() async {
    final otpError = validateOtp(_otp);
    if (otpError != null) {
      setState(() => _error = otpError);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await context
          .read<AppState>()
          .repos
          .auth
          .verifyPhoneOtp(_verificationId ?? '', _otp);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Phone sign-in')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(FxSpacing.lg),
          child: _otpStep ? _buildOtpStep() : _buildPhoneStep(),
        ),
      ),
    );
  }

  Widget _buildPhoneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Enter your phone number', style: FxText.headline),
        const SizedBox(height: 8),
        Text(
          'We\'ll send a one-time code to verify it.',
          style: FxText.body.copyWith(color: FxColors.secondaryText),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonHideUnderline(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                decoration: BoxDecoration(
                  color: FxColors.white,
                  border: Border.all(color: FxColors.borders),
                  borderRadius: BorderRadius.circular(FxRadius.md),
                ),
                child: DropdownButton<String>(
                  value: _countryCode,
                  items: _countryCodes
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _countryCode = v ?? '+91'),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FxTextField(
                controller: _phoneCtrl,
                label: 'Phone number',
                hint: '98765 43210',
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: FxColors.error)),
        ],
        const SizedBox(height: 24),
        FxButton(
          label: 'Send OTP',
          loading: _loading,
          onPressed: _loading ? null : _sendOtp,
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Enter the code', style: FxText.headline),
        const SizedBox(height: 8),
        Text(
          'Sent to $_fullPhone',
          style: FxText.body.copyWith(color: FxColors.secondaryText),
        ),
        if (AppConfig.useDemoData) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(FxSpacing.md),
            decoration: BoxDecoration(
              color: FxColors.warning.withOpacity(0.12),
              borderRadius: BorderRadius.circular(FxRadius.md),
            ),
            child: const Text(
              'Demo mode: any 6-digit OTP works.',
              style: TextStyle(color: FxColors.navy, fontSize: 13),
            ),
          ),
        ],
        const SizedBox(height: 24),
        _otpBoxes(),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: FxColors.error)),
        ],
        const SizedBox(height: 24),
        FxButton(
          label: 'Verify & continue',
          loading: _loading,
          onPressed: _loading ? null : _verify,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _secondsLeft > 0 || _loading ? null : _sendOtp,
          child: Text(
            _secondsLeft > 0
                ? 'Resend code in $_secondsLeft s'
                : 'Resend code',
          ),
        ),
        TextButton(
          onPressed: _loading
              ? null
              : () => setState(() {
                    _otpStep = false;
                    _error = null;
                  }),
          child: const Text('Change phone number'),
        ),
      ],
    );
  }

  Widget _otpBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        return SizedBox(
          width: 48,
          child: TextField(
            controller: _otpCtrls[i],
            focusNode: _otpNodes[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700),
            onChanged: (v) {
              if (v.length == 1 && i < 5) {
                _otpNodes[i + 1].requestFocus();
              } else if (v.isEmpty && i > 0) {
                _otpNodes[i - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }
}
