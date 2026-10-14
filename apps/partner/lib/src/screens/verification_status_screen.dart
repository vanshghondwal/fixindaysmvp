/// Verification status gate: shows the real application status and blocks
/// the dashboard until the application is approved.
///
/// In demo mode a clearly labelled "simulate approval" button lets the demo
/// continue past this gate (no real review happens).
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/partner_state.dart';
import 'partner_gate.dart';
import 'support_screen.dart';
import 'verification_apply_screen.dart';

class VerificationStatusScreen extends StatefulWidget {
  const VerificationStatusScreen({super.key});

  @override
  State<VerificationStatusScreen> createState() =>
      _VerificationStatusScreenState();
}

class _VerificationStatusScreenState extends State<VerificationStatusScreen> {
  bool _busy = false;

  Future<void> _simulateApproval() async {
    setState(() => _busy = true);
    try {
      final state = context.read<PartnerState>();
      await state.ops.simulateApproval(state.user!.id);
      await state.refreshPartnerData();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PartnerGate()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not update: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOut() async {
    final ok = await fxConfirm(
      context,
      title: 'Sign out?',
      message: 'You will need to sign in again to continue.',
      confirmLabel: 'Sign out',
    );
    if (!ok || !mounted) return;
    final state = context.read<PartnerState>();
    await state.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PartnerGate()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PartnerState>();
    final app = state.application;
    final status = app?.status ?? VerificationStatus.pending;

    return Scaffold(
      appBar: AppBar(title: const Text('Verification status')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(FxSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _statusCard(status, app?.adminNote),
                  const SizedBox(height: 16),
                  if (status == VerificationStatus.pending) ...[
                    const Text(
                      'Your application is under review. The dashboard '
                      'unlocks once an admin approves it.',
                      style: FxText.body,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FxButton(
                      label: 'Simulate admin approval (demo only)',
                      loading: _busy,
                      onPressed: _busy ? null : _simulateApproval,
                      icon: Icons.science_outlined,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Demo only — no real review happens. In production an '
                      'admin approves applications from the admin panel.',
                      style: FxText.caption,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (status == VerificationStatus.rejected ||
                      status == VerificationStatus.needsInfo) ...[
                    FxButton(
                      label: 'Update application',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                const VerificationApplyScreen()),
                      ),
                    ),
                  ],
                  if (status == VerificationStatus.suspended) ...[
                    FxButton(
                      label: 'Contact support',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const SupportScreen()),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _signOut,
                    child: const Text('Sign out'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusCard(VerificationStatus status, String? adminNote) {
    final (icon, title, message, color) = switch (status) {
      VerificationStatus.pending => (
          Icons.hourglass_top_outlined,
          'Application under review',
          'We are checking your details. This usually takes up to 2 business days.',
          FxColors.warning,
        ),
      VerificationStatus.needsInfo => (
          Icons.info_outline,
          'More information needed',
          'Please update your application with the requested details.',
          FxColors.warning,
        ),
      VerificationStatus.rejected => (
          Icons.cancel_outlined,
          'Application not approved',
          'Your application was not approved. See the note below.',
          FxColors.error,
        ),
      VerificationStatus.suspended => (
          Icons.block_outlined,
          'Account suspended',
          'Your partner account is suspended. Contact support for help.',
          FxColors.error,
        ),
      _ => (
          Icons.check_circle_outline,
          'Verified',
          'Your application is approved.',
          FxColors.primary,
        ),
    };
    return FxCard(
      child: Column(
        children: [
          Icon(icon, size: 56, color: color),
          const SizedBox(height: 12),
          Text(title, style: FxText.title, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(message,
              style: FxText.caption, textAlign: TextAlign.center),
          if (adminNote != null && adminNote.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(FxSpacing.md),
              decoration: BoxDecoration(
                color: FxColors.background,
                borderRadius: BorderRadius.circular(FxRadius.md),
                border: Border.all(color: FxColors.borders),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Note from the review team',
                      style: FxText.subtitle),
                  const SizedBox(height: 4),
                  Text(adminNote, style: FxText.body),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
