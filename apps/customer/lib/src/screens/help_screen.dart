/// Help & Support: FAQ accordion, support contact (demo values labelled),
/// and a "Report issue" entry point.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';

import 'dispute_screen.dart';

class _Faq {
  final String q;
  final String a;
  const _Faq(this.q, this.a);
}

const _faqs = [
  _Faq(
    'How do I book a service?',
    'Browse categories or search for what you need, open a provider, add '
        'services to your cart, pick an address and a time slot, then confirm. '
        'You pay cash after the service is done.',
  ),
  _Faq(
    'How do payments work?',
    'Online payments aren\'t configured yet (see FIREBASE_SETUP.md at the '
        'repo root). For now you pay the provider in cash after the job. '
        'Nothing is charged inside this build.',
  ),
  _Faq(
    'Can I cancel or reschedule a booking?',
    'Yes — open the booking and use Cancel or Reschedule. Cancellation is '
        'free until the provider accepts your booking; afterwards it follows '
        'the cancellation policy shown at booking time.',
  ),
  _Faq(
    'Are providers verified?',
    'Providers with the verified badge have passed document verification. '
        'Unverified providers are clearly labelled so you can decide.',
  ),
  _Faq(
    'How do reviews work?',
    'After a completed booking you can rate the provider 1–5 stars and leave '
        'a comment. One review per booking, and only for bookings you made.',
  ),
  _Faq(
    'What if something goes wrong?',
    'Use “Report an issue” below (or on any completed/cancelled booking) to '
        'raise a support ticket. Every ticket is reviewed by the support team.',
  ),
];

// Demo contact details — replaced by real ones after backend setup.
const _support = PlatformSettings(
  supportPhone: '+91-11-4000-0000',
  supportEmail: 'support@fixindays.in',
);

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return VoiceScreenTag(
      screenKey: 'help',
      child: Scaffold(
      appBar: AppBar(title: Text(t.t('helpSupport'))),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(FxSpacing.md),
              children: [
                const FxSectionHeader(
                    title: 'Frequently asked questions'),
                const SizedBox(height: 8),
                ..._faqs.map((f) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: 8),
                      child: FxCard(
                        padding: EdgeInsets.zero,
                        child: ExpansionTile(
                          title: Text(f.q,
                              style: FxText.subtitle),
                          children: [
                            Padding(
                              padding: const EdgeInsets
                                  .fromLTRB(16, 0, 16, 16),
                              child: Text(f.a,
                                  style: FxText.body),
                            ),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 16),
                const FxSectionHeader(title: 'Contact support'),
                const SizedBox(height: 8),
                FxCard(
                  child: Column(
                    children: [
                      _contactRow(Icons.phone_outlined,
                          'Phone', _support.supportPhone),
                      const Divider(),
                      _contactRow(Icons.email_outlined,
                          'Email', _support.supportEmail),
                      const SizedBox(height: 4),
                      const Text(
                        'Demo contact details — replaced with real ones '
                        'after backend setup.',
                        style: FxText.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FxButton(
                  label: 'Report an issue',
                  kind: FxButtonKind.outlined,
                  icon: Icons.report_outlined,
                  onPressed: () =>
                      Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) =>
                            const DisputeScreen()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _contactRow(
      IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: FxColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: FxText.caption),
              Text(value, style: FxText.body),
            ],
          ),
        ),
      ],
    );
  }
}
