import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

// Placeholder tab. Only functional bit kept is Log Out, since that
// used to live on DashboardScreen — moving it here makes more sense
// UX-wise and keeps DashboardScreen's own logout button as a backup.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const Color bg = Color(0xFFF2EEEC);

  Future<void> _logout(BuildContext context) async {
    await AuthService().signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.settings, color: Color(0xFF9AA0D8), size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Settings',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Coming soon — preferences, account,\nand security settings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => _logout(context),
                  child: const Text('Log out',
                      style: TextStyle(color: Colors.black54)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}