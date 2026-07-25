import 'package:flutter/material.dart';

// Placeholder tab. No logic — this exists only so the bottom nav has
// a real destination for the "Notifications" icon. Fill in real
// content later if time allows before launch day.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const Color bg = Color(0xFFF2EEEC);

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
              children: const [
                Icon(Icons.notifications, color: Color(0xFFF5B342), size: 48),
                SizedBox(height: 16),
                Text(
                  'Notifications',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 8),
                Text(
                  'Coming soon — this tab will show streak reminders\nand task alerts.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}