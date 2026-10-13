import 'package:firebase_core/firebase_core.dart';
import 'package:fixindays_core/fixindays_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'src/screens/login_screen.dart';
import 'src/state/admin_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseReady = false;
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    firebaseReady = true;
  } catch (_) {
    // No firebase_options.dart yet (or init failed) — fall back to clearly
    // labelled demo mode instead of crashing. See FIREBASE_SETUP.md.
    firebaseReady = false;
  }
  AppConfig.useDemoData = !firebaseReady;
  runApp(FixinDaysAdminApp(demoMode: !firebaseReady));
}

class FixinDaysAdminApp extends StatelessWidget {
  final bool demoMode;
  const FixinDaysAdminApp({super.key, required this.demoMode});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminState(demoMode: demoMode),
      child: MaterialApp(
        title: 'FixinDays Admin',
        debugShowCheckedModeBanner: false,
        theme: FxTheme.light(),
        localizationsDelegates: const [
          FxLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('hi')],
        home: const AdminLoginGate(),
      ),
    );
  }
}
