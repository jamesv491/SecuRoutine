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

  // Sign out
  Future<void> signOut() => _auth.signOut();

  // Current user (null if not signed in)
  User? get currentUser => _auth.currentUser;
}