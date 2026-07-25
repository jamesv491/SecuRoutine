// Loads the task pool from assets/data/task_pool.json instead of a
// hardcoded Dart list. This addresses the Progress Report 2 feedback
// to strengthen the task data model: tasks can now be added, edited,
// or removed by editing the JSON file alone, with no changes to
// application/Dart code required.
//
// The result is cached in memory after the first successful load,
// since the pool doesn't change during a session and this can be
// called on every "New Set" tap.
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

List<Map<String, dynamic>>? _cachedTaskPool;

Future<List<Map<String, dynamic>>> loadTaskPool() async {
  if (_cachedTaskPool != null) return _cachedTaskPool!;

  final raw = await rootBundle.loadString('lib/assets/data/task_pool.json');
  final decoded = jsonDecode(raw) as List<dynamic>;

  _cachedTaskPool =
      decoded.map((t) => Map<String, dynamic>.from(t as Map)).toList();

  return _cachedTaskPool!;
}