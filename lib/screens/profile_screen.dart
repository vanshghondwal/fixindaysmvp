import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/app_state.dart';

/// Profile tab — simple profile; auth via Firebase Auth once connected.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: FixTheme.primary,
                    child: Icon(Icons.person,
                        color: Colors.white, size: 36),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.userName,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text(state.userAddress,
                          style: const TextStyle(
                              color: Colors.black54)),
                      const Text('Demo mode — Firebase Auth pending',
                          style: TextStyle(
                              fontSize: 11, color: Colors.orange)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _row(Icons.location_on, 'My Addresses', () {}),
          _row(Icons.history, 'Service History', () {}),
          _row(Icons.star_outline, 'My Reviews', () {}),
          _row(Icons.support_agent, 'Help & Support', () {}),
          _row(Icons.info_outline, 'About FixinDays', () {
            showAboutDialog(
              context: context,
              applicationName: 'FixinDays',
              applicationVersion: '1.0.0 (demo)',
              children: const [
                Text(
                    'Same Services. Brighter Days.\n\nA local home services platform connecting you with trusted service providers.\n\nBuilt by Team FixinDays (Vansh, Divyansh, Nikhil) for InnoHacks 4.0 — Open Innovation track.'),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: FixTheme.primary),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
