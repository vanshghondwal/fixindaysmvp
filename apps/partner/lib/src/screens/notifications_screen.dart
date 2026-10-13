/// Notifications: live stream, tap to mark read.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/partner_state.dart';
import '../widgets/booking_card.dart' show formatDay;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _attempt = 0;

  IconData _iconFor(NotificationKind kind) {
    return switch (kind) {
      NotificationKind.booking => Icons.event_outlined,
      NotificationKind.payment => Icons.payments_outlined,
      NotificationKind.review => Icons.star_outline,
      NotificationKind.support => Icons.support_agent_outlined,
      NotificationKind.system => Icons.info_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    final state = context.read<PartnerState>();
    final user = state.user;

    return Scaffold(
      appBar: AppBar(title: Text(t.t('notifications'))),
      body: Column(
        children: [
          if (AppConfig.useDemoData) const DemoBanner(),
          if (user == null)
            const Expanded(
              child: Center(child: Text('Please sign in.')),
            )
          else
            Expanded(
              child: StreamBuilder<List<NotificationItem>>(
                key: ValueKey(_attempt),
                stream: state.notifications.watch(user.id),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const SingleChildScrollView(
                      padding: EdgeInsets.all(FxSpacing.lg),
                      child: FxLoadingList(),
                    );
                  }
                  if (snap.hasError) {
                    return ErrorPanel(
                      message: snap.error.toString(),
                      onRetry: () =>
                          setState(() => _attempt++),
                    );
                  }
                  final items = snap.data ?? const [];
                  if (items.isEmpty) {
                    return const EmptyState(
                      icon: Icons.notifications_outlined,
                      title: 'No notifications',
                      message:
                          'Booking requests, reviews and updates will appear here.',
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(FxSpacing.lg),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final n = items[i];
                      return FxCard(
                        onTap: n.read
                            ? null
                            : () =>
                                state.notifications.markRead(n.id),
                        padding: const EdgeInsets.symmetric(
                            horizontal: FxSpacing.md, vertical: 12),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: (n.read
                                        ? FxColors.secondaryText
                                        : FxColors.primary)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(
                                    FxRadius.md),
                              ),
                              child: Icon(
                                _iconFor(n.kind),
                                color: n.read
                                    ? FxColors.secondaryText
                                    : FxColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          n.title,
                                          style: n.read
                                              ? FxText.body
                                              : FxText.subtitle,
                                        ),
                                      ),
                                      if (!n.read)
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration:
                                              const BoxDecoration(
                                            color: FxColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(n.body,
                                      style: FxText.caption),
                                  const SizedBox(height: 4),
                                  Text(formatDay(n.createdAt),
                                      style: FxText.caption),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
