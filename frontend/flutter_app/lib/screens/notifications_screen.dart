import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color bg = Color(0xFFF2EEEC);
  static const Color accent = Color(0xFFF5B342);
  static const Color readColor = Color(0xFF4CAF50); // green for read state

  final AuthService _authService = AuthService();

  // Tracks the in-flight "Mark all read" request so we can show a small
  // loading state on the button and surface errors instead of failing
  // silently (e.g. if a Firestore permission/index error is thrown).
  bool _markingAllRead = false;

  // BUG FIX: because MainShell keeps every tab alive inside an
  // IndexedStack (built once from a const list), this screen's
  // initState() only ever runs ONE time for the whole app session —
  // not every time the user taps into the "Alerts" tab. Previously
  // checkAndGenerateNotifications() was only called from initState,
  // so time-sensitive notifications (like the "streak about to reset"
  // warning, which only qualifies once hourUtc >= 23) would never be
  // generated if that condition wasn't already true the one time this
  // ran at app startup — even if the user kept the app open past that
  // point. A full page reload was the only way to see it.
  //
  // Fix: re-run the check on a timer while this screen stays mounted,
  // so time-based conditions get re-evaluated periodically instead of
  // just once. The StreamBuilder below is already listening to
  // Firestore in real time, so as soon as a new notification doc is
  // written the list updates automatically — no manual refresh needed.
  Timer? _refreshTimer;
  static const _refreshInterval = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    // Initial check when the app/tab first builds.
    _authService.checkAndGenerateNotifications();

    // Periodic re-check so time-sensitive notifications (streak
    // warning near end-of-day) still get generated even if the app
    // was opened well before the threshold and never reloaded.
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      _authService.checkAndGenerateNotifications();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleMarkAllRead() async {
    if (_markingAllRead) return;
    setState(() => _markingAllRead = true);
    try {
      await _authService.markAllNotificationsRead();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not mark all as read: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _markingAllRead = false);
    }
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'streak_warning':
        return Icons.warning_amber_rounded;
      case 'task_reminder':
      default:
        return Icons.local_fire_department;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'streak_warning':
        return Colors.redAccent;
      case 'task_reminder':
      default:
        return accent;
    }
  }

  String _timeAgo(Timestamp? ts) {
    if (ts == null) return '';
    final diff = DateTime.now().toUtc().difference(ts.toDate().toUtc());
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _authService.getNotificationsStream(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    TextButton(
                      onPressed: _markingAllRead ? null : _handleMarkAllRead,
                      child: _markingAllRead
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Mark all read',
                              style: TextStyle(fontSize: 13, color: Colors.black54),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Reminders about today\'s tasks and your streak.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 20),

                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (docs.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: const Center(
                      child: Text(
                        'You\'re all caught up.\nNo reminders right now.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.black45),
                      ),
                    ),
                  )
                else
                  ...docs.map((doc) {
                    final data = doc.data();
                    final type = data['type'] as String? ?? 'task_reminder';
                    final unread = !(data['read'] as bool? ?? false);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _NotificationTile(
                        icon: _iconFor(type),
                        iconColor: _colorFor(type),
                        title: data['title'] as String? ?? '',
                        subtitle: data['message'] as String? ?? '',
                        time: _timeAgo(data['created_at'] as Timestamp?),
                        unread: unread,
                        accent: accent,
                        readColor: readColor,
                        onTap: () {
                          if (unread) {
                            _authService.markNotificationRead(doc.id);
                          }
                        },
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final bool unread;
  final Color accent;
  final Color readColor;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.unread,
    required this.accent,
    required this.readColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Border + status indicator now have three visually distinct states:
    // unread -> orange, read -> green. (There is no "neutral" state
    // anymore; every notification is either unread or read.)
    final borderColor = unread ? accent.withOpacity(0.5) : readColor.withOpacity(0.45);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: unread ? 1 : 1.2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (unread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                          ),
                        )
                      else
                        Icon(
                          Icons.check_circle,
                          color: readColor,
                          size: 16,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    time,
                    style: const TextStyle(fontSize: 11, color: Colors.black38),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}