/// Simple in-app chat with a provider.
///
/// Mock messages only; in production this would stream from Firestore.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String providerName;

  const ChatScreen({super.key, required this.providerName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatMessage {
  final String text;
  final bool fromMe;
  final String time;

  const _ChatMessage({
    required this.text,
    required this.fromMe,
    required this.time,
  });
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _messages = <_ChatMessage>[
    const _ChatMessage(
        text: 'Namaste! Main aapki service ke liye aa raha hoon.',
        fromMe: false,
        time: '10:24 AM'),
    const _ChatMessage(
        text: 'Kitne baje tak pahuchenge?',
        fromMe: true,
        time: '10:26 AM'),
    const _ChatMessage(
        text: 'Bas 15 minute mein, location pe hoon.',
        fromMe: false,
        time: '10:27 AM'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(
          text: text, fromMe: true, time: 'now'));
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaxScaffold(
      appBar: AppBar(
        backgroundColor: MaxColors.cream,
        foregroundColor: MaxColors.ink,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: MaxColors.orangeSoft,
                borderRadius: BorderRadius.circular(13),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.providerName.isNotEmpty
                    ? widget.providerName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: MaxColors.orangeDeep),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.providerName,
                      style: MaxText.title.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: MaxColors.mint,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('Online',
                          style: MaxText.caption),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: false,
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                return Align(
                  alignment: m.fromMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(
                      maxWidth:
                          MediaQuery.of(context).size.width *
                              0.75,
                    ),
                    decoration: BoxDecoration(
                      gradient: m.fromMe
                          ? MaxColors.heroGradient
                          : null,
                      color: m.fromMe
                          ? null
                          : MaxColors.cardWhite,
                      borderRadius: BorderRadius.circular(18)
                          .copyWith(
                        bottomRight: m.fromMe
                            ? Radius.zero
                            : const Radius.circular(18),
                        bottomLeft: m.fromMe
                            ? const Radius.circular(18)
                            : Radius.zero,
                      ),
                      boxShadow:
                          maxShadow(m.fromMe ? MaxColors.orange : MaxColors.inkFaint, blur: 8),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,
                      children: [
                        Text(
                          m.text,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: m.fromMe
                                ? Colors.white
                                : MaxColors.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m.time,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: m.fromMe
                                ? Colors.white
                                    .withValues(alpha: 0.8)
                                : MaxColors.inkFaint,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            decoration: const BoxDecoration(
              color: MaxColors.cardWhite,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message…',
                      hintStyle: MaxText.caption,
                      filled: true,
                      fillColor: MaxColors.cream,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    gradient: MaxColors.heroGradient,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded,
                        color: Colors.white),
                    onPressed: _send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
