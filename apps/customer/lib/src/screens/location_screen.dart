/// Location onboarding: explains why the address is needed, offers a
/// (honestly unavailable) GPS option, and collects a manual address.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';

import 'address_form_screen.dart';
import 'root_shell.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  void _useCurrentLocation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Location unavailable'),
        content: const Text(
          'Live GPS location needs a Google Maps API key, which isn\'t '
          'configured yet. Add it per FIREBASE_SETUP.md at the repo root, '
          'then this button will fetch your current position.\n\n'
          'For now, please enter your address manually.',
        ),
        actions: [
          FxButton(
            label: 'OK',
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  Future<void> _addManually(BuildContext context) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddressFormScreen()),
    );
    if (saved == true && context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RootShell()),
        (_) => false,
      );
    }
  }

  void _skip(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RootShell()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.t('yourLocation'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(FxSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const FxCard(
                child: Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 40, color: FxColors.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Providers need your address to reach you and to '
                        'show only pros who serve your area.',
                        style: FxText.body,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FxButton(
                label: 'Use current location',
                icon: Icons.my_location,
                onPressed: () => _useCurrentLocation(context),
              ),
              const SizedBox(height: 4),
              const Text(
                'Needs a Maps API key — see FIREBASE_SETUP.md.',
                style: FxText.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FxButton(
                label: 'Enter address manually',
                kind: FxButtonKind.outlined,
                icon: Icons.edit_location_outlined,
                onPressed: () => _addManually(context),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _skip(context),
                child: const Text('Skip for now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
