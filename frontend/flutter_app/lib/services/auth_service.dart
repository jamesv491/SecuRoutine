import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

      // Streak/task tracking fields
      'last_active_date': today,
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
        'last_active_date': today,
        'today_tasks': [],
        'last_task_generation_date': today,
      };
      await docRef.update(patch);
      data.addAll(patch);
    }

    return data;
  }

  // Complete a task: mark it completed, add points, recalculate level.
  // Uses a transaction so concurrent writes don't corrupt the task list.
  Future<void> completeTask(String taskId, int points) async {
    final uid = _auth.currentUser!.uid;
    final docRef = _db.collection('users').doc(uid);

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

      tx.update(docRef, {
        'today_tasks': tasks,
        'total_points': newPoints,
        'current_level': newLevel,
      });
    });
  }

  // Skip a task: mark it skipped, no points awarded.
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

  // Temporary helper to seed demo tasks when today_tasks is empty.
  // This exists only until real task generation (filtered by
  // security_preference) is implemented. Once that logic exists,
  // this function can be removed and replaced with generateNewTaskSet().
  Future<void> seedTasksIfEmpty(List<Map<String, dynamic>> defaultTasks) async {
    final uid = _auth.currentUser!.uid;
    final docRef = _db.collection('users').doc(uid);
    final snap = await docRef.get();
    final data = snap.data();
    if (data == null) return;

    final List existing = data['today_tasks'] ?? [];
    if (existing.isNotEmpty) return;

    final today = DateTime.now().toIso8601String().substring(0, 10);
    await docRef.update({
      'today_tasks':
          defaultTasks.map((t) => {...t, 'status': 'pending'}).toList(),
      'last_task_generation_date': today,
    });
  }

  // Sign out
  Future<void> signOut() => _auth.signOut();

  // Current user (null if not signed in)
  User? get currentUser => _auth.currentUser;
}