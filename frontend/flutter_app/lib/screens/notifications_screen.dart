import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const Color bg = Color(0xFFF2EEEC);
  static const Color mint = Color(0xFF7DD3C0);

  @override
  Widget build(BuildContext context) {
    // Simple static notifications for now
    final notifications = [
      {
        'title': 'Keep your streak alive!',
        'body': 'Complete today\'s tasks to continue your streak.',
        'time': 'Today',
      },
      {
        'title': 'New security tip',
        'body': 'Enable 2FA on your most important accounts.',
        'time': 'Yesterday',
      },
      {
        'title': 'Level up!',
        'body': 'You reached a new level. Keep going!',
        'time': '2 days ago',
      },
    ];

    return Scaffold(backgroundColor: bg, body: SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(20), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ const Text('Notifications', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 24),
        Expanded(child: ListView.separated(itemCount: notifications.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {final n = notifications[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 10, height: 10,
              margin: const EdgeInsets.only(top: 6),
              decoration: const BoxDecoration(color: mint,shape: BoxShape.circle,
          ),
          ),
          const SizedBox(width: 14),
          Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(n['title']!, style: const TextStyle(fontWeight: FontWeight.w700,fontSize: 16,
              ),
              ),
            const SizedBox(height: 4),
              Text(n['body']!, style: const TextStyle(fontSize: 14, color: Colors.black54,
                ),
                ),
            const SizedBox(height: 6),
              Text(n['time']!, style: const TextStyle(fontSize: 12, color: Colors.black38,
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