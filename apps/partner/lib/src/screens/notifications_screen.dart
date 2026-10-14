/// Notifications — maximalism edition.
///
/// Colorful cards per notification kind, NEW pills on unread items,
/// tap to mark read.
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

  (Color, Color) _colorsFor(NotificationKind kind) {
    return switch (kind) {
      NotificationKind.booking => (MaxColors.skySoft, MaxColors.sky),
      NotificationKind.payment => (MaxColors.mintSoft, MaxColors.mint),
      NotificationKind.review => (MaxColors.sunSoft, const Color(0xFFB8860B)),
      NotificationKind.support => (MaxColors.purpleSoft, MaxColors.purple),
      NotificationKind.system => (MaxColors.creamDeep, MaxColors.inkSoft),
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    final state = context.read<PartnerState>();
    final user = state.user;

    return MaxScaffold(
      appBar: AppBar(
        backgroundColor: MaxColors.cream,
        foregroundColor: MaxColors.ink,
        elevation: 0,
        title: Text(t.t('notifications'), style: MaxText.title),
      ),
      body: Column(
        children: [
          if (user == null)
            const Expanded(
              child: Center(
                  child: Text('Please sign in.',
                      style: MaxText.body)),
            )
          else
            Expanded(
              child: StreamBuilder<List<NotificationItem>>(
                key: ValueKey(_attempt),
                stream: state.notifications.watch(user.id),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const SingleChildScrollView(
                      padding: EdgeInsets.all(16),
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
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final n = items[i];
                      final (bg, fg) = _colorsFor(n.kind);
                      return Opacity(
                        opacity: n.read ? 0.72 : 1.0,
                        child: MaxCard(
                          shadowColor: n.read ? MaxColors.inkFaint : fg,
                          onTap: n.read
                              ? null
                              : () =>
                                  state.notifications.markRead(n.id),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: bg,
                                  borderRadius:
                                      BorderRadius.circular(15),
                                ),
                                child: Icon(
                                  _iconFor(n.kind),
                                  color: fg,
                                  size: 24,
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
                                                ? MaxText.body.copyWith(
                                                    fontWeight:
                                                        FontWeight.w700)
                                                : MaxText.title.copyWith(
                                                    fontSize: 15),
                                          ),
                                        ),
                                        if (!n.read)
                                          const MaxPill(
                                              label: 'NEW',
                                              bg: MaxColors.coralSoft,
                                              fg: MaxColors.coral),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(n.body,
                                        style: MaxText.body.copyWith(
                                            fontSize: 13)),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3),
                                      decoration: BoxDecoration(
                                        color: MaxColors.creamDeep,
                                        borderRadius:
                                            BorderRadius.circular(99),
                                      ),
                                      child: Text(
                                          formatDay(n.createdAt),
                                          style: MaxText.caption.copyWith(
                                              fontSize: 11)),
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
    );
  }
}
