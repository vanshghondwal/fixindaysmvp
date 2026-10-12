import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../models/models.dart';
import '../data/mock_data.dart';
import '../services/app_state.dart';

/// Booking flow: slot select → address → confirm.
/// Mirrors the deck's booking step; writes to AppState (mock),
/// FirebaseService.saveBooking when connected.
class BookingScreen extends StatefulWidget {
  final Provider provider;
  const BookingScreen({super.key, required this.provider});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _dateIndex = 0;
  int _timeIndex = 0;
  final _addressCtrl = TextEditingController();
  final _serviceCtrl = TextEditingController();

  @override
  void dispose() {
    _addressCtrl.dispose();
    _serviceCtrl.dispose();
    super.dispose();
  }

  void _confirm(BuildContext context) {
    final state = context.read<AppState>();
    if (_addressCtrl.text.trim().isEmpty) {
      _addressCtrl.text = state.userAddress;
    }
    final booking = Booking(
      id: 'b${DateTime.now().millisecondsSinceEpoch}',
      providerName: widget.provider.name,
      serviceName: _serviceCtrl.text.trim().isEmpty
          ? widget.provider.services.first
          : _serviceCtrl.text.trim(),
      dateLabel: MockData.slotDates()[_dateIndex],
      timeLabel: MockData.timeSlots[_timeIndex],
      address: _addressCtrl.text.trim(),
      price: widget.provider.priceOnwards,
    );
    state.addBooking(booking);
    final messenger = ScaffoldMessenger.of(context);
    final providerName = widget.provider.name;
    final dateLabel = booking.dateLabel;
    Navigator.popUntil(context, (r) => r.isFirst);
    messenger.showSnackBar(
      SnackBar(
        content:
            Text('✅ Booked! $providerName will reach you on $dateLabel.'),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;
    final dates = MockData.slotDates();
    return Scaffold(
      appBar: AppBar(title: Text('Book — ${p.name}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provider summary
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: FixTheme.primary,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Row(children: [
                  Text(p.name,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                  if (p.verified)
                    const Icon(Icons.verified,
                        size: 16, color: FixTheme.accent),
                ]),
                subtitle: Text(
                    '⭐ ${p.rating}  ·  ₹${p.priceOnwards} onwards  ·  ${p.distance}'),
              ),
            ),
            const SizedBox(height: 16),
            const Text('What needs fixing?',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _serviceCtrl,
              decoration: InputDecoration(
                hintText: 'e.g. ${p.services.first}',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Pick a day',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(dates.length, (i) {
                final sel = i == _dateIndex;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(dates[i],
                          style: TextStyle(
                              fontSize: 12,
                              color: sel
                                  ? Colors.white
                                  : Colors.black87)),
                      selected: sel,
                      selectedColor: FixTheme.primary,
                      onSelected: (_) =>
                          setState(() => _dateIndex = i),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            const Text('Pick a time slot',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(MockData.timeSlots.length, (i) {
                final sel = i == _timeIndex;
                return ChoiceChip(
                  label: Text(MockData.timeSlots[i],
                      style: TextStyle(
                          color:
                              sel ? Colors.white : Colors.black87)),
                  selected: sel,
                  selectedColor: FixTheme.primary,
                  onSelected: (_) =>
                      setState(() => _timeIndex = i),
                );
              }),
            ),
            const SizedBox(height: 16),
            const Text('Service address',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _addressCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: context
                    .read<AppState>()
                    .userAddress,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            // Price summary
            Card(
              color: FixTheme.primaryDark,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total (starting)',
                        style: TextStyle(color: Colors.white70)),
                    Text('₹${p.priceOnwards}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _confirm(context),
                style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Confirm Booking',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
