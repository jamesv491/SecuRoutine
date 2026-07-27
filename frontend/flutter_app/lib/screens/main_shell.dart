import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'notifications_screen.dart';
import 'tasks_screen.dart';
import 'settings_screen.dart';

// Owns the bottom navigation bar and keeps each tab's state alive via
// IndexedStack (so switching tabs doesn't rebuild DashboardScreen and
// re-trigger _loadProfile every time). DashboardScreen itself no
// longer renders its own bottomNavigationBar — this widget is the
// single source of truth for tab switching.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const Color bg = Color(0xFFF2EEEC);

  final List<Widget> _tabs = const [
    DashboardScreen(),
    NotificationsScreen(),
    TasksScreen(),
    SettingsScreen(),
  ];

  void _onTabTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _bottomNav() {
    final items = [
      (Icons.home, 'Home', const Color(0xFFE07A5A)),
      (Icons.notifications, 'Alerts', const Color(0xFFF5B342)),
      (Icons.assignment, 'Tasks', const Color(0xFFE08A5A)),
      (Icons.settings, 'Settings', const Color(0xFF9AA0D8)),
    ];

  return Container(
    decoration: const BoxDecoration(color: bg,
      border: Border(top: BorderSide(color: Color(0xFFDDD7D0))),
    ),
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(items.length, (index) {
        final (icon, label, color) = items[index];
        final isSelected = _currentIndex == index;

      return GestureDetector(
        onTap: () => _onTabTap(index),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(mainAxisSize: MainAxisSize.min,
          children: [
          Icon(
            icon, color: isSelected ? color : color.withValues(alpha: 0.35), size: isSelected ? 28 : 26,
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? color : Colors.black38,
            ),
          ),
            ],
          ),
        ),
      );
    }),
  ),
  );
}
}