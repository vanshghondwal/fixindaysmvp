/// Notifications inbox: stream from the repository, mark-read on tap.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  late Stream<List<NotificationItem>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = _watch();
  }

  Stream<List<NotificationItem>> _watch() {
    final app = context.read<AppState>();
    return app.repos.notifications.watch(app.user!.id);
  }

  IconData _iconFor(NotificationKind kind) {
    switch (kind) {
      case NotificationKind.booking:
        return Icons.calendar_month_outlined;
      case NotificationKind.payment:
        return Icons.payments_outlined;
      case NotificationKind.review:
        return Icons.star_outline;
      case NotificationKind.support:
        return Icons.support_agent_outlined;
      case NotificationKind.system:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    final t = FxLocalizations.of(context);
    return VoiceScreenTag(
      screenKey: 'notifications',
      child: Scaffold(
      appBar: AppBar(title: Text(t.t('notifications'))),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<NotificationItem>>(
              stream: _stream,
              builder: (_, snap) {
                if (snap.connectionState ==
                    ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(FxSpacing.md),
                    child: FxLoadingList(),
                  );
                }
                if (snap.hasError) {
                  return ErrorPanel(
                    message: snap.error.toString(),
                    onRetry: () =>
                        setState(() => _stream = _watch()),
                  );
                }
                final items = snap.data ?? [];
                if (items.isEmpty) {
                  return const EmptyState(
                    icon:
                        Icons.notifications_off_outlined,
                    title: 'No notifications yet',
                    message:
                        'Booking updates and offers will appear here.',
                  );
                }
                return ListView.builder(
                  padding:
                      const EdgeInsets.all(FxSpacing.md),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final n = items[i];
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: 8),
                      child: FxCard(
                        onTap: () => app.repos.notifications
                            .markRead(n.id),
                        child: Row(
                          children: [
                            Icon(_iconFor(n.kind),
                                color: FxColors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                            n.title,
                                            style: n.read
                                                ? FxText
                                                    .body
                                                : FxText
                                                    .subtitle),
                                      ),
                                      if (!n.read)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration:
                                              const BoxDecoration(
                                            color: FxColors
                                                .primary,
                                            shape:
                                                BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(n.body,
                                      style: FxText.caption),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat(
                                            'd MMM · h:mm a')
                                        .format(n.createdAt),
                                    style: FxText.caption,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ));
  }
}
