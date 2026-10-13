/// Payment: HONEST — online payments are not configured yet.
///
/// Only "Cash on service" is offered (enabled per PlatformSettings in demo).
/// Online payment is never faked as successful.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'booking_confirmation_screen.dart';

// Demo platform settings until the admin panel / backend provides them.
const _platformSettings = PlatformSettings();

class PaymentScreen extends StatefulWidget {
  final BookingDraft draft;

  const PaymentScreen({super.key, required this.draft});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _payCash() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final app = context.read<AppState>();
      final booking =
          await app.repos.bookings.createBooking(
        customerId: app.user!.id,
        providerId: widget.draft.provider.id,
        items: widget.draft.items,
        addressSnapshot: widget.draft.address.short,
        addressId: widget.draft.address.id,
        scheduledAt: widget.draft.scheduledAt,
        notes: widget.draft.notes.isEmpty
            ? null
            : widget.draft.notes,
      );
      app.cart.clear();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(
            booking: booking,
            cashOnService: true,
          ),
        ),
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
    final d = widget.draft;
    final cashEnabled = _platformSettings.cashOnServiceEnabled;
    return Scaffold(
      appBar: AppBar(title: Text(t.t('payment'))),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(FxSpacing.md),
              children: [
                const FxCard(
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: FxColors.warning, size: 32),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text('Online payments not set up yet',
                                style: FxText.subtitle),
                            SizedBox(height: 4),
                            Text(
                              'UPI/cards need Razorpay credentials — see '
                              'FIREBASE_SETUP.md at the repo root. Nothing '
                              'is charged in this build.',
                              style: FxText.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Payment method', style: FxText.title),
                const SizedBox(height: 8),
                FxCard(
                  child: RadioGroup<bool>(
                    groupValue: true,
                    onChanged: (_) {},
                    child: RadioListTile<bool>(
                      value: true,
                      enabled: cashEnabled,
                      title: Text(t.t('cashOnService')),
                      subtitle: Text(
                        cashEnabled
                            ? 'Pay the provider directly after the job. (Works in demo.)'
                            : 'Disabled by platform settings.',
                      ),
                      secondary: const Icon(
                          Icons.payments_outlined,
                          color: FxColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FxCard(
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Amount due after service',
                          style: FxText.subtitle),
                      Text(
                          formatInr(d.totals.totalPaise),
                          style: FxText.price
                              .copyWith(fontSize: 20)),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: const TextStyle(
                          color: FxColors.error)),
                ],
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(FxSpacing.md),
              child: FxButton(
                label:
                    'Confirm booking · ${formatInr(d.totals.totalPaise)} cash',
                loading: _loading,
                onPressed:
                    (cashEnabled && !_loading) ? _payCash : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
