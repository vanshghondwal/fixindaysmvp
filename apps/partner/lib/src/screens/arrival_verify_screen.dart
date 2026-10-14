/// Arrival-code verification: the customer shares a 4-digit code, the
/// provider enters it, and the booking moves to in-progress.
///
/// The check runs through [ProviderOpsRepository.transitionBooking], which
/// validates the code with [arrivalCodeMatches] (demo code lives only in
/// the demo data layer — never on a real model).
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/partner_state.dart';

class ArrivalVerifyScreen extends StatefulWidget {
  final String bookingId;

  const ArrivalVerifyScreen({super.key, required this.bookingId});

  @override
  State<ArrivalVerifyScreen> createState() => _ArrivalVerifyScreenState();
}

class _ArrivalVerifyScreenState extends State<ArrivalVerifyScreen> {
  final _codeCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<PartnerState>().ops.transitionBooking(
            widget.bookingId,
            BookingStatus.inProgress,
            arrivalCode: _codeCtrl.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on StateError catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Could not verify: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify arrival code')),
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
                    const Icon(Icons.pin_outlined,
                        size: 64, color: FxColors.primary),
                    const SizedBox(height: 16),
                    const Text(
                      'Ask the customer for the 4-digit arrival code shown '
                      'in their app, then enter it below to start the job.',
                      style: FxText.body,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline,
                            size: 16, color: FxColors.warning),
                        SizedBox(width: 8),
                        Text(
                          'Demo: the customer code for this job is 4821.',
                          style: FxText.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    FxTextField(
                      controller: _codeCtrl,
                      label: 'Arrival code',
                      hint: '4 digits',
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          RegExp(r'^[0-9]{4}$').hasMatch((v ?? '').trim())
                              ? null
                              : 'Enter the 4-digit code',
                    ),
                    // Keep the numeric keyboard to 4 digits.
                    const SizedBox(height: 4),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding:
                            const EdgeInsets.all(FxSpacing.md),
                        decoration: BoxDecoration(
                          color: FxColors.error.withValues(alpha: 0.08),
                          borderRadius:
                              BorderRadius.circular(FxRadius.md),
                          border: Border.all(
                              color:
                                  FxColors.error.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: FxColors.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_error!,
                                  style: FxText.body.copyWith(
                                      color: FxColors.error)),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FxButton(
                      label: 'Start service',
                      loading: _busy,
                      onPressed: _busy ? null : _verify,
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
