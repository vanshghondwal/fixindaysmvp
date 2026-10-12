import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'services/app_state.dart';
// import 'services/firebase_service.dart'; // uncomment after `flutterfire configure`
import 'screens/home_screen.dart';
import 'screens/bookings_screen.dart';
import 'screens/profile_screen.dart';

/// FixinDays — Same Services. Brighter Days.
/// InnoHacks 4.0 · Open Innovation · Team FixinDays (Vansh, Divyansh, Nikhil)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await FirebaseService.init(); // TODO(firebase): enable after connecting
  runApp(const FixinDaysApp());
}

class FixinDaysApp extends StatelessWidget {
  const FixinDaysApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'FixinDays',
        debugShowCheckedModeBanner: false,
        theme: FixTheme.light(),
        home: const RootNav(),
      ),
    );
  }
}

/// Bottom navigation: Home / Bookings / Profile — matches deck architecture.
class RootNav extends StatefulWidget {
  const RootNav({super.key});

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;

  static const _tabs = [
    HomeScreen(),
    BookingsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
