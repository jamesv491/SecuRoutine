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
      (_currentIndex == 0, Icons.home, const Color(0xFFE07A5A)),
      (_currentIndex == 1, Icons.notifications, const Color(0xFFF5B342)),
      (_currentIndex == 2, Icons.assignment, const Color(0xFFE08A5A)),
      (_currentIndex == 3, Icons.settings, const Color(0xFF9AA0D8)),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: Color(0xFFDDD7D0))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (index) {
          final (isSelected, icon, color) = items[index];
          return GestureDetector(
            onTap: () => _onTabTap(index),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Icon(
                icon,
                color: isSelected ? color : color.withOpacity(0.35),
                size: isSelected ? 30 : 28,
              ),
            ),
          );
        }),
      ),
    );
  }
}