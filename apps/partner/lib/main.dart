/// FixinDays Partner — the provider-side app.
///
/// Demo mode is ON ([AppConfig.useDemoData] == true): Firebase init is
/// attempted but failures are swallowed, and the app runs on the in-memory
/// demo repositories. See README.md and FIREBASE_SETUP.md.
library;

import 'package:firebase_core/firebase_core.dart';
import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'src/screens/splash_screen.dart';
import 'src/state/partner_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Demo mode: Firebase is not configured yet (see FIREBASE_SETUP.md).
    // The app continues on in-memory demo repositories.
  }
  runApp(const PartnerApp());
}

class PartnerApp extends StatelessWidget {
  const PartnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PartnerState()),
        ProxyProvider<PartnerState, AppUser?>(
          update: (_, state, __) => state.user,
        ),
        ProxyProvider<PartnerState, Locale>(
          update: (_, state, __) => state.locale,
        ),
      ],
      child: Builder(
        builder: (context) {
          final locale = context.watch<Locale>();
          return MaterialApp(
            title: 'FixinDays Partner',
            theme: FxTheme.light(),
            locale: locale,
            localizationsDelegates: const [
              FxLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('hi')],
            home: const PartnerSplash(),
          );
        },
      ),
    );
  }
}
