/// Verification application: explains verification, lists required documents.
///
/// Document upload buttons are HONESTLY disabled in demo mode — Firebase
/// Storage is not connected. The application can still be submitted with a
/// declaration checkbox (demo flow).
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/partner_state.dart';
import 'partner_gate.dart';

class VerificationApplyScreen extends StatefulWidget {
  const VerificationApplyScreen({super.key});

  @override
  State<VerificationApplyScreen> createState() =>
      _VerificationApplyScreenState();
}

class _VerificationApplyScreenState extends State<VerificationApplyScreen> {
  bool _declared = false;
  bool _submitting = false;

  static const _docs = [
    ('ID proof', 'Aadhaar / PAN / Driving licence', Icons.badge_outlined),
    ('Address proof', 'Utility bill / rent agreement',
        Icons.home_outlined),
    ('Trade certificate', 'Trade licence or skill certificate',
        Icons.workspace_premium_outlined),
  ];

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final state = context.read<PartnerState>();
      // Demo: no documents can be uploaded yet (Storage not connected), so
      // the application is submitted with an empty document set.
      await state.ops.submitApplication(state.user!.id, {});
      await state.refreshPartnerData();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PartnerGate()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not submit: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Get verified')),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(FxSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FxCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.verified_outlined,
                                color: FxColors.primary, size: 28),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text('Why verification?',
                                  style: FxText.title),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Verified partners get a badge on their profile, '
                          'rank higher in search and receive more booking '
                          'requests. Review usually takes 2 business days.',
                          style: FxText.body,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const FxSectionHeader(title: 'Required documents'),
                  const SizedBox(height: 8),
                  ..._docs.map((d) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: FxSpacing.sm),
                        child: FxCard(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(d.$3,
                                      color: FxColors.primary),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(d.$1,
                                            style: FxText.subtitle),
                                        Text(d.$2,
                                            style: FxText.caption),
                                      ],
                                    ),
                                  ),
                                  const FxButton(
                                    label: 'Upload (soon)',
                                    kind: FxButtonKind.outlined,
                                    // Disabled in demo: Firebase Storage
                                    // is not connected yet.
                                    onPressed: null,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Document upload needs Firebase Storage — '
                                'see FIREBASE_SETUP.md.',
                                style: FxText.caption,
                              ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: _declared,
                    onChanged: (v) =>
                        setState(() => _declared = v ?? false),
                    controlAffinity:
                        ListTileControlAffinity.leading,
                    title: const Text(
                      'I declare that the business details I provided are '
                      'true, and I agree to the FixinDays partner terms '
                      '(demo).',
                      style: FxText.body,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FxButton(
                    label: t.t('submit'),
                    loading: _submitting,
                    onPressed:
                        (_declared && !_submitting) ? _submit : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
