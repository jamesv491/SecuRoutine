import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  Map<String, dynamic>? _profile;
  bool _loading = true;

  // ---- Palette ----
  static const Color bg = Color(0xFFF2EEEC);
  static const Color mint = Color(0xFF3FBF8F);
  static const Color darkBtn = Color(0xFF111111);
  static const Color skipBtn = Color(0xFF9C8C6E);
  static const Color glitchRed = Color(0xFFFF5A5A);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Loads the profile from Firestore. Checks/resets streak first, then
  // regenerates today_tasks if the stored set is from a previous day
  // (fixes bugs 010/011/012 — previously this only regenerated when
  // today_tasks was literally empty, so a finished set from yesterday
  // just stayed there showing "Completed" until the user manually
  // tapped "New Set"). Falls back to generating a set for brand-new
  // profiles that don't have one yet.
  //
  // Guards each setState with a mounted check, since this runs several
  // awaits deep (Firestore reads/writes) and the widget can be disposed
  // mid-flight — e.g. if the app hot-restarts or the user navigates away
  // while a call is still in progress. Without this, the completed
  // Future would try to setState() on a State object that's no longer
  // in the tree and throw.
  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() => _loading = true);

    await _authService.checkAndUpdateStreak();
    await _authService.refreshTaskSetForNewDay();

    var data = await _authService.getProfile();
    final List existingTasks = data?['today_tasks'] ?? [];
    if (existingTasks.isEmpty) {
      await _authService.generateNewTaskSet();
      data = await _authService.getProfile();
    }

    if (!mounted) return;
    setState(() {
      _profile = data;
      _loading = false;
    });
  }

  // Marks a task as completed and refreshes the dashboard state
  Future<void> _completeTask(Map<String, dynamic> task) async {
    final points = (task['points'] as num?)?.toInt() ?? 0;
    await _authService.completeTask(task['id'] as String, points);
    await _loadProfile();
  }

  // Marks a task as skipped and refreshes the dashboard state
  Future<void> _skipTask(Map<String, dynamic> task) async {
    await _authService.skipTask(task['id'] as String);
    await _loadProfile();
  }

  // Requests a brand new task set from the pool, replacing today_tasks
  Future<void> _newSet() async {
    await _authService.generateNewTaskSet();
    await _loadProfile();
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
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

    final name = _profile?['display_name'] ?? 'User';
    final streak = _profile?['current_streak'] ?? 0;
    final points = _profile?['total_points'] ?? 0;
    final level = _profile?['current_level'] ?? 1;

    // "Done" is derived from today_tasks rather than stored separately
    final List todayTasks = _profile?['today_tasks'] ?? [];
    final done = todayTasks.where((t) => t['status'] == 'completed').length;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(name, '$streak'),
              const SizedBox(height: 20),
              _statsRow('$points', '$level', '$done'),
              const SizedBox(height: 28),
              _tasksHeader(),
              const SizedBox(height: 14),
              for (final t in todayTasks) ...[
                _taskCard(Map<String, dynamic>.from(t)),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 8),
              TextButton(
                onPressed: _logout,
                child: const Text('Log out',
                    style: TextStyle(color: Colors.black54)),
              ),
            ],
          ),
        ),
      ),
      // NOTE: bottomNavigationBar removed from here — MainShell now owns
      // the nav bar and swaps tabs via IndexedStack. Keeping a second
      // nav bar here would duplicate it when DashboardScreen is nested
      // inside MainShell.
    );
  }

  // ---------- HEADER ----------
  Widget _header(String name, String streak) {
    return Column(
      children: [
        const Text(
          'SECUROUTINE',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
            color: mint,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Welcome back,\n$name',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.notifications, color: Color(0xFFF5B342), size: 34),
            SizedBox(width: 28),
            Icon(Icons.assignment, color: Color(0xFFE08A5A), size: 34),
            SizedBox(width: 28),
            Icon(Icons.settings, color: Color(0xFF9AA0D8), size: 34),
          ],
        ),
        const SizedBox(height: 18),
        const Text(
          'STREAK:',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        _glitchNumber(streak),
      ],
    );
  }

  Widget _glitchNumber(String text) {
    const style = TextStyle(fontSize: 88, fontWeight: FontWeight.w900);
    return SizedBox(
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: const Offset(4, 3),
            child: Text(text, style: style.copyWith(color: glitchRed)),
          ),
          Transform.translate(
            offset: const Offset(-3, -2),
            child: Text(text, style: style.copyWith(color: mint)),
          ),
          Text(text, style: style.copyWith(color: mint)),
        ],
      ),
    );
  }

  // ---------- STATS ROW ----------
  Widget _statsRow(String points, String level, String done) {
    return Row(
      children: [
        Expanded(child: _statCard('Points', points)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Level', level)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Done', done)),
      ],
    );
  }

  Widget _statCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- TASKS ----------
  Widget _tasksHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Today's Tasks",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        // Wired to generateNewTaskSet() via _newSet
        GestureDetector(
          onTap: _newSet,
          child: const Text(
            'New Set',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _taskCard(Map<String, dynamic> t) {
    final status = t['status'] as String? ?? 'pending';
    final isPending = status == 'pending';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: mint, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t['name'] as String? ?? '',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t['description'] as String? ?? '',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 20),
          // Show action buttons only while the task is still pending.
          // Once completed or skipped, show a status label instead.
          if (isPending)
            Row(
              children: [
                Expanded(
                  child: _pillButton(
                    label: 'Complete (+${t['points']})',
                    color: darkBtn,
                    onTap: () => _completeTask(t),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _pillButton(
                    label: 'Skip',
                    color: skipBtn,
                    onTap: () => _skipTask(t),
                  ),
                ),
              ],
            )
          else
            Text(
              status == 'completed' ? 'Completed' : 'Skipped',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: status == 'completed' ? mint : Colors.black45,
              ),
            ),
        ],
      ),
    );
  }

  Widget _pillButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}