/// Bank details — payout account form (maximalism edition).
///
/// Mock save: edits stay in local state only. Real banking hook-up is a
/// TODO for the backend integration.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  late final TextEditingController _holderCtrl;
  late final TextEditingController _accountCtrl;
  late final TextEditingController _ifscCtrl;
  late final TextEditingController _upiCtrl;

  @override
  void initState() {
    super.initState();
    // Mock previously-saved payout details.
    _holderCtrl = TextEditingController(text: 'Rajesh Kumar');
    _accountCtrl = TextEditingController(text: '50100234567890');
    _ifscCtrl = TextEditingController(text: 'HDFC0001234');
    _upiCtrl = TextEditingController(text: 'rajesh@upi');
  }

  @override
  void dispose() {
    _holderCtrl.dispose();
    _accountCtrl.dispose();
    _ifscCtrl.dispose();
    _upiCtrl.dispose();
    super.dispose();
  }

  void _save() {
    // Mock save — nothing leaves the device.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bank details saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaxScaffold(
      appBar: AppBar(
        backgroundColor: MaxColors.cream,
        foregroundColor: MaxColors.ink,
        elevation: 0,
        title: const Text('Bank details', style: MaxText.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MaxHeroCard(
                    gradient: MaxColors.oceanGradient,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.account_balance_outlined,
                                color: Colors.white, size: 28),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text('Payout account',
                                  style: MaxText.onGradientBig),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Weekly earnings land in this account every Monday.',
                          style: MaxText.onGradient
                              .copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const MaxSectionHeader(title: 'Account info'),
                  const SizedBox(height: 8),
                  FxTextField(
                    controller: _holderCtrl,
                    label: 'Account holder name',
                    hint: 'Name as on the bank account',
                  ),
                  const SizedBox(height: 12),
                  FxTextField(
                    controller: _accountCtrl,
                    label: 'Account number',
                    hint: '10–18 digit account number',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  FxTextField(
                    controller: _ifscCtrl,
                    label: 'IFSC code',
                    hint: 'e.g. HDFC0001234',
                  ),
                  const SizedBox(height: 12),
                  FxTextField(
                    controller: _upiCtrl,
                    label: 'UPI ID',
                    hint: 'yourname@upi',
                  ),
                  const SizedBox(height: 24),
                  MaxButton(
                    label: 'Save bank details',
                    icon: Icons.save_outlined,
                    onPressed: _save,
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
