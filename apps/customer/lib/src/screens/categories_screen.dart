/// All service categories in a grid.
library;

import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'category_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Future<List<ServiceCategory>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<ServiceCategory>> _load() =>
      context.read<AppState>().repos.catalog.categories();

  @override
  Widget build(BuildContext context) {
    final t = FxLocalizations.of(context);
    final lang = context.watch<AppState>().locale.languageCode;
    return VoiceScreenTag(
      screenKey: 'categories',
      child: Scaffold(
      appBar: AppBar(title: Text(t.t('allCategories'))),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<ServiceCategory>>(
              future: _future,
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
                        setState(() => _future = _load()),
                  );
                }
                final cats = snap.data ?? [];
                if (cats.isEmpty) {
                  return const EmptyState(
                    icon: Icons.category_outlined,
                    title: 'No categories',
                    message:
                        'Categories will appear here once added.',
                  );
                }
                return GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(FxSpacing.md),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: cats
                      .map((c) => CategoryTile(
                            name: c.name(lang),
                            icon: categoryIcon(c.iconName),
                            onTap: () =>
                                Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    CategoryDetailScreen(
                                        category: c),
                              ),
                            ),
                          ))
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
    ));
  }
}
