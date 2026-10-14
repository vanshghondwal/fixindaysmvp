/// Training & certification — module list (maximalism edition).
///
/// Local demo state only: tapping a module toggles its completion.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';

class _Module {
  final String title;
  final String description;
  final String duration;
  final Color accent;
  double progress;
  bool completed;

  _Module({
    required this.title,
    required this.description,
    required this.duration,
    required this.accent,
    required this.progress,
    required this.completed,
  });
}

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  late final List<_Module> _modules;

  @override
  void initState() {
    super.initState();
    // Mock curriculum — demo progress snapshot.
    _modules = [
      _Module(
        title: 'Customer service basics',
        description: 'Greeting customers, polite communication, handling queries.',
        duration: '25 min',
        accent: MaxColors.mint,
        progress: 1.0,
        completed: true,
      ),
      _Module(
        title: 'Safety & tools handling',
        description: 'Safe tool usage, PPE, and on-site safety checklists.',
        duration: '40 min',
        accent: MaxColors.orange,
        progress: 1.0,
        completed: true,
      ),
      _Module(
        title: 'Hygiene & sanitation',
        description: 'Keeping homes clean before, during and after a job.',
        duration: '20 min',
        accent: MaxColors.sky,
        progress: 1.0,
        completed: true,
      ),
      _Module(
        title: 'On-time arrival mastery',
        description: 'Route planning, buffers, and communicating delays.',
        duration: '15 min',
        accent: MaxColors.purple,
        progress: 0.5,
        completed: false,
      ),
      _Module(
        title: 'Upselling politely',
        description: 'Suggesting add-on services without being pushy.',
        duration: '30 min',
        accent: MaxColors.pink,
        progress: 0.0,
        completed: false,
      ),
    ];
  }

  void _toggle(_Module module) {
    setState(() {
      module.completed = !module.completed;
      module.progress = module.completed ? 1.0 : 0.0;
    });
  }

  double get _overall =>
      _modules.isEmpty
          ? 0.0
          : _modules
                  .map((m) => m.progress)
                  .reduce((a, b) => a + b) /
              _modules.length;

  @override
  Widget build(BuildContext context) {
    final pct = (_overall * 100).round();

    return MaxScaffold(
      appBar: AppBar(
        backgroundColor: MaxColors.cream,
        foregroundColor: MaxColors.ink,
        elevation: 0,
        title:
            const Text('Training & certification', style: MaxText.title),
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
                    gradient: MaxColors.mintGradient,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text('$pct% complete',
                                  style: MaxText.onGradientBig),
                            ),
                            const Icon(Icons.school_outlined,
                                color: Colors.white, size: 32),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Complete all modules to earn the FixinDays Certified badge.',
                          style: MaxText.onGradient
                              .copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: _overall,
                            minHeight: 10,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.25),
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const MaxSectionHeader(title: 'Modules'),
                  const SizedBox(height: 8),
                  for (final module in _modules)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _moduleCard(module),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _moduleCard(_Module module) {
    final pct = (module.progress * 100).round();
    return MaxCard(
      onTap: () => _toggle(module),
      shadowColor: module.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: module.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  module.completed
                      ? Icons.check_circle
                      : Icons.play_circle_outline,
                  color: module.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(module.title,
                        style: MaxText.title.copyWith(fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(module.duration,
                        style: MaxText.body.copyWith(
                            color: MaxColors.inkFaint, fontSize: 12)),
                  ],
                ),
              ),
              MaxPill(
                label: module.completed ? 'Done' : '$pct%',
                bg: module.accent.withValues(alpha: 0.15),
                fg: module.accent,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(module.description,
              style:
                  MaxText.body.copyWith(color: MaxColors.inkSoft)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: module.progress,
              minHeight: 8,
              backgroundColor: MaxColors.line,
              valueColor:
                  AlwaysStoppedAnimation<Color>(module.accent),
            ),
          ),
        ],
      ),
    );
  }
}
