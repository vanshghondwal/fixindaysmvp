/// Broadcast announcements: writes to the `announcements` collection.
/// Honest limitation: delivering these as push notifications requires FCM
/// to be configured in the customer/partner apps (see FIREBASE_SETUP.md).
/// Until then they are stored in-app only.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/admin_state.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _body = TextEditingController();
  bool _posting = false;
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _reload(initial: true);
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetch() {
    final state = context.read<AdminState>();
    final demo = state.demoRepo;
    if (demo != null) return demo.announcements();
    return state.firestoreRepo!.announcements();
  }

  void _reload({bool initial = false}) {
    final f = _fetch();
    if (initial) {
      _future = f;
    } else {
      setState(() => _future = f);
    }
  }

  Future<void> _post() async {
    if (!_formKey.currentState!.validate()) return;
    final state = context.read<AdminState>();
    setState(() => _posting = true);
    try {
      final demo = state.demoRepo;
      if (demo != null) {
        await demo.postAnnouncement(_title.text.trim(), _body.text.trim());
      } else {
        await state.firestoreRepo!.postAnnouncement(
            _title.text.trim(), _body.text.trim(), state.adminId);
      }
      if (!mounted) return;
      _title.clear();
      _body.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Announcement published (in-app; push needs FCM).')));
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(FxSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FxSectionHeader(title: 'New announcement'),
          const SizedBox(height: FxSpacing.md),
          Form(
            key: _formKey,
            child: Column(
              children: [
                FxTextField(
                  controller: _title,
                  label: 'Title',
                  hint: 'e.g. Diwali maintenance offer',
                  validator: (v) => validateRequired(v, 'Title'),
                ),
                const SizedBox(height: FxSpacing.md),
                FxTextField(
                  controller: _body,
                  label: 'Message',
                  hint: 'What should users know?',
                  maxLines: 4,
                  validator: (v) => validateRequired(v, 'Message'),
                ),
                const SizedBox(height: FxSpacing.md),
                const Text(
                  'Stored in the announcements collection. Push delivery to '
                  'devices requires FCM setup in the customer/partner apps — '
                  'see FIREBASE_SETUP.md.',
                  style: FxText.caption,
                ),
                const SizedBox(height: FxSpacing.md),
                FxButton(
                  label: 'Publish',
                  loading: _posting,
                  icon: Icons.campaign_outlined,
                  onPressed: _posting ? null : _post,
                ),
              ],
            ),
          ),
          const SizedBox(height: FxSpacing.lg),
          const FxSectionHeader(title: 'Published'),
          const SizedBox(height: FxSpacing.md),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const FxLoadingList(count: 3);
              }
              if (snap.hasError) {
                return ErrorPanel(
                    message: '${snap.error}', onRetry: () => _reload());
              }
              final items = snap.data!;
              if (items.isEmpty) {
                return const EmptyState(
                  icon: Icons.campaign_outlined,
                  title: 'No announcements',
                  message: 'Published announcements will appear here.',
                );
              }
              return Column(
                children: [
                  for (final a in items)
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: FxSpacing.sm),
                      child: FxCard(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text('${a['title'] ?? ''}',
                                style: FxText.subtitle),
                            const SizedBox(height: 4),
                            Text('${a['body'] ?? ''}',
                                style: FxText.body),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
