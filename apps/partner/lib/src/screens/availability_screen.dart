/// Availability: working days, open/close times and an optional break note.
///
/// Stored in memory on the device in demo mode — honestly labelled as
/// "synced to Firestore after Firebase connect".
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/partner_state.dart';

const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  late Set<int> _days;
  late TimeOfDay _open;
  late TimeOfDay _close;
  late final TextEditingController _breakCtrl;

  @override
  void initState() {
    super.initState();
    final s = context.read<PartnerState>();
    _days = Set<int>.from(s.workingDays);
    _open = s.openTime;
    _close = s.closeTime;
    _breakCtrl = TextEditingController(text: s.breakNote);
  }

  @override
  void dispose() {
    _breakCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isOpen) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isOpen ? _open : _close,
    );
    if (picked != null) {
      setState(() {
        if (isOpen) {
          _open = picked;
        } else {
          _close = picked;
        }
      });
    }
  }

  void _save() {
    if (_days.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Select at least one working day.')),
      );
      return;
    }
    final openMin = _open.hour * 60 + _open.minute;
    final closeMin = _close.hour * 60 + _close.minute;
    if (closeMin <= openMin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Closing time must be after opening time.')),
      );
      return;
    }
    context.read<PartnerState>().setAvailability(
          days: _days,
          open: _open,
          close: _close,
          breakNote: _breakCtrl.text.trim(),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Availability saved on this device (demo).')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Availability')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                          'Demo: availability is stored on this device only. '
                          'It will sync to Firestore after Firebase is connected.',
                          style: FxText.caption,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Working days', style: FxText.subtitle),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(7, (i) {
                      final day = i + 1; // 1 = Monday
                      final selected = _days.contains(day);
                      return FilterChip(
                        label: Text(_dayNames[i]),
                        selected: selected,
                        onSelected: (_) => setState(() {
                          if (selected) {
                            _days.remove(day);
                          } else {
                            _days.add(day);
                          }
                        }),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _timeTile(
                            'Opens', _open, () => _pickTime(true)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _timeTile(
                            'Closes', _close, () => _pickTime(false)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FxTextField(
                    controller: _breakCtrl,
                    label: 'Break note (optional)',
                    hint: 'e.g. Lunch break 1–2 PM',
                  ),
                  const SizedBox(height: 24),
                  FxButton(label: t.t('save'), onPressed: _save),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeTile(String label, TimeOfDay time, VoidCallback onTap) {
    return FxCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: FxText.caption),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(time.format(context), style: FxText.title),
              const Spacer(),
              const Icon(Icons.schedule,
                  color: FxColors.secondaryText),
            ],
          ),
        ],
      ),
    );
  }
}
