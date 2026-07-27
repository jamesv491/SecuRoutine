import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _authService = AuthService();
  Map<String, dynamic>? _profile;
  bool _loading = true;

  static const Color bg = Color(0xFFF2EEEC);
  static const Color mint = Color(0xFF7DD3C0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _authService.getProfile();
    if (mounted) {
      setState(() {
        _profile = data;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: bg,
        body: Center(child: CircularProgressIndicator(color: mint)),
      );
    }

    final List todayTasks = _profile?['today_tasks'] ?? [];

    return Scaffold(backgroundColor: bg,
    body: SafeArea(
      child: Padding(
      padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text('Tasks',style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text('Your current daily set',style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: todayTasks.isEmpty ? const Center(child: Text('No tasks yet')) : ListView.separated(
                    itemCount: todayTasks.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final t = Map<String, dynamic>.from(todayTasks[index]);
                      final status = t['status'] ?? 'pending';
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: status == 'completed' ? mint : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                                status == 'completed' ? Icons.check_circle : status == 'skipped'
                                      ? Icons.cancel
                                      : Icons.radio_button_unchecked,
                                color: status == 'completed' ? mint : status == 'skipped'
                                      ? Colors.orange
                                      : Colors.grey,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t['name'] ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(t['description'] ?? '',
                                    style: const TextStyle(fontSize: 13, color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  ),
);
}
}