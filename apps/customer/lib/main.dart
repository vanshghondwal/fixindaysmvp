/// FixinDays customer app entry point.
///
/// Demo mode is ON until Firebase is configured (see FIREBASE_SETUP.md at the
/// repo root). Firebase.initializeApp() is attempted best-effort: if it
/// fails (no google-services config yet) the app keeps running on clearly
/// labelled demo data with a "Demo mode" banner.
library;

import 'package:firebase_core/firebase_core.dart';
import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'src/screens/splash_screen.dart';
import 'src/state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // No Firebase configuration yet — stay in demo mode.
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const FixinDaysCustomerApp(),
    ),
  );
}

class FixinDaysCustomerApp extends StatelessWidget {
  const FixinDaysCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<AppState>().locale;
    return MaterialApp(
      title: 'FixinDays',
      debugShowCheckedModeBanner: false,
      theme: FxTheme.light(),
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('hi')],
      localizationsDelegates: const [
        FxLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
