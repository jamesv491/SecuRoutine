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
  static const Color darkBtn = Color(0xFF111111);
  static const Color skipBtn = Color(0xFF9C8C6E);
  static const Color glitchRed = Color(0xFFFF5A5A);

  // Task demo data (no Firestore task collection yet)
  static const List<Map<String, dynamic>> _tasks = [
    {
      'title': 'Review recent login activity',
      'subtitle': 'Check whether recent sign in activity looks normal.',
      'reward': 13,
    },
    {
      'title': 'Review privacy settings',
      'subtitle': 'Check privacy permissions on your main account.',
      'reward': 10,
    },
    {
      'title': 'Change an old password',
      'subtitle': 'Update one password that has not been changed recently.',
      'reward': 10,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await _authService.getProfile();
    setState(() {
      _profile = data;
      _loading = false;
    });
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
    final done = _profile?['completed_today'] ?? 0;

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
              for (final t in _tasks) ...[
                _taskCard(t),
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
      bottomNavigationBar: _bottomNav(),
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
      children: const [
        Text(
          "Today's Tasks",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        Text(
          'New Set',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _taskCard(Map<String, dynamic> t) {
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
            t['title'] as String,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t['subtitle'] as String,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _pillButton(
                  label: 'Complete (+${t['reward']})',
                  color: darkBtn,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _pillButton(
                  label: 'Skip',
                  color: skipBtn,
                  onTap: () {},
                ),
              ),
            ],
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

  // ---------- BOTTOM NAV ----------
  Widget _bottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: Color(0xFFDDD7D0))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          Icon(Icons.home, color: Color(0xFFE07A5A), size: 28),
          Icon(Icons.notifications, color: Color(0xFFF5B342), size: 28),
          Icon(Icons.assignment, color: Color(0xFFE08A5A), size: 28),
          Icon(Icons.settings, color: Color(0xFF9AA0D8), size: 28),
        ],
      ),
    );
  }
}