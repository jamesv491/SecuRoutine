import 'package:flutter/material.dart';

// Placeholder tab for the "Assignment" nav icon. Intended future use:
// a history/log view of past completed & skipped tasks. No logic yet.
class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

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
                Icon(Icons.assignment, color: Color(0xFFE08A5A), size: 48),
                SizedBox(height: 16),
                Text(
                  'Task History',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 8),
                Text(
                  'Coming soon — a log of your completed\nand skipped tasks over time.',
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