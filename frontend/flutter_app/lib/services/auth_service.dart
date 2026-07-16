import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/task_pool.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sign in with email + password
  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Register a new account
  Future<UserCredential> register(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Save the profile to Firestore (collection "users", document = uid)
  Future<void> saveProfile({
    required String displayName,
    required String experienceLevel,
    required String ageGroup,
    required String securityPreference,
  }) async {
    final uid = _auth.currentUser!.uid;
    final today = DateTime.now().toIso8601String().substring(0, 10);

    await _db.collection('users').doc(uid).set({
      'display_name': displayName,
      'experience_level': experienceLevel,
      'age_group': ageGroup,
      'security_preference': securityPreference,
      'current_streak': 0,
      'total_points': 0,
      'current_level': 1,
      'created_at': FieldValue.serverTimestamp(),

      // last_active_date left null on purpose — it should only be set
      // the first time a full day's task set is completed, not at
      // account creation
      'last_active_date': null,
      'today_tasks': [],
      'last_task_generation_date': today,
    });
  }

  // Read the profile from Firestore, backfilling new fields if missing
  Future<Map<String, dynamic>?> getProfile() async {
    final uid = _auth.currentUser!.uid;
    final docRef = _db.collection('users').doc(uid);
    final doc = await docRef.get();
    final data = doc.data();

    if (data == null) return null;

    // Backfill for accounts created before these fields existed
    if (!data.containsKey('today_tasks')) {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final patch = {
        'last_active_date': null,
        'today_tasks': [],
        'last_task_generation_date': today,
      };
      await docRef.update(patch);
      data.addAll(patch);
    }

    return data;
  }

  // Check streak status when the app opens. If the user missed a full
  // day (last_active_date isn't today or yesterday), reset the streak
  // to 0. If they were active yesterday, leave the streak as is — it
  // will be incremented by completeTask() once they complete every
  // task for today.
  Future<void> checkAndUpdateStreak() async {
    final uid = _auth.currentUser!.uid;
    final docRef = _db.collection('users').doc(uid);
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final snap = await docRef.get();
    final data = snap.data();
    if (data == null) return;

    final lastActive = data['last_active_date'] as String?;
    if (lastActive == null || lastActive == today) return;

    final yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .substring(0, 10);

    if (lastActive != yesterday) {
      // Missed at least one full day -> reset streak
      await docRef.update({'current_streak': 0});
    }
  }

  // Complete a task: mark it completed and add points/level immediately.
  // The streak only increments once every task in today_tasks has been
  // completed (skipped tasks do not count toward finishing the day),
  // and only once per day.
  Future<void> completeTask(String taskId, int points) async {
    final uid = _auth.currentUser!.uid;
    final docRef = _db.collection('users').doc(uid);
    final today = DateTime.now().toIso8601String().substring(0, 10);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final data = snap.data();
      if (data == null) return;

      final List tasks = List.from(data['today_tasks'] ?? []);
      final idx = tasks.indexWhere((t) => t['id'] == taskId);
      if (idx == -1 || tasks[idx]['status'] != 'pending') return;

      // Copy the map so we don't mutate a read-only structure from Firestore
      tasks[idx] = Map<String, dynamic>.from(tasks[idx]);
      tasks[idx]['status'] = 'completed';

      final newPoints = (data['total_points'] ?? 0) + points;
      final newLevel = (newPoints ~/ 100) + 1; // 100 points per level

      final update = <String, dynamic>{
        'today_tasks': tasks,
        'total_points': newPoints,
        'current_level': newLevel,
      };

      // Only credit the streak if EVERY task for today is now completed
      // (none left pending or skipped)
      final allCompleted = tasks.every((t) => t['status'] == 'completed');

      if (allCompleted) {
        final lastActive = data['last_active_date'] as String?;

        if (lastActive != today) {
          int streak = (data['current_streak'] ?? 0) as int;

          if (lastActive != null) {
            final yesterday = DateTime.now()
                .subtract(const Duration(days: 1))
                .toIso8601String()
                .substring(0, 10);
            streak = (lastActive == yesterday) ? streak + 1 : 1;
          } else {
            streak = 1;
          }

          update['current_streak'] = streak;
          update['last_active_date'] = today;
        }
      }

      tx.update(docRef, update);
    });
  }

  // Skip a task: mark it skipped, no points awarded. Skipping removes
  // the possibility of completing the full set for today, so it does
  // not contribute toward the streak.
  Future<void> skipTask(String taskId) async {
    final uid = _auth.currentUser!.uid;
    final docRef = _db.collection('users').doc(uid);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final data = snap.data();
      if (data == null) return;

      final List tasks = List.from(data['today_tasks'] ?? []);
      final idx = tasks.indexWhere((t) => t['id'] == taskId);
      if (idx == -1) return;

      tasks[idx] = Map<String, dynamic>.from(tasks[idx]);
      tasks[idx]['status'] = 'skipped';

      tx.update(docRef, {'today_tasks': tasks});
    });
  }

  // Generates a new set of daily tasks from the local task pool.
  // Guarantees at least one task matches the user's security_preference,
  // the rest are picked at random from the remaining pool to avoid a
  // repeated experience, per the original design report.
  Future<void> generateNewTaskSet({int setSize = 3}) async {
    final uid = _auth.currentUser!.uid;
    final docRef = _db.collection('users').doc(uid);
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final snap = await docRef.get();
    final data = snap.data();
    if (data == null) return;

    final preference = data['security_preference'] as String?;
    final random = Random();

    final matching =
        taskPool.where((t) => t['category'] == preference).toList()
          ..shuffle(random);
    final others =
        taskPool.where((t) => t['category'] != preference).toList()
          ..shuffle(random);

    final selected = <Map<String, dynamic>>[];

    // At least one task always matches the user's stated preference
    if (matching.isNotEmpty) {
      selected.add(matching.first);
    }

    for (final t in others) {
      if (selected.length >= setSize) break;
      selected.add(t);
    }

    // Fallback in case the pool doesn't have enough tasks to fill setSize
    while (selected.length < setSize && selected.length < taskPool.length) {
      final candidate = taskPool[random.nextInt(taskPool.length)];
      if (!selected.any((t) => t['id'] == candidate['id'])) {
        selected.add(candidate);
      }
    }

    await docRef.update({
      'today_tasks': selected.map((t) => {...t, 'status': 'pending'}).toList(),
      'last_task_generation_date': today,
    });
  }

  // Sign out
  Future<void> signOut() => _auth.signOut();

  // Current user (null if not signed in)
  User? get currentUser => _auth.currentUser;
}