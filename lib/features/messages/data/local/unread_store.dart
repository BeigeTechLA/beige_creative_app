import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistent, per-user unread-count store. Writes are debounced so bursts of
/// bumps don't hammer disk.
///
/// Key layout: `unread_v1:<userId>` → JSON `{ roomId: count }`.
/// Cleared on logout via [clearForUser].
class UnreadStore {
  UnreadStore(this._userId);

  final String _userId;
  Timer? _writeDebounce;
  static const Duration _writeDelay = Duration(milliseconds: 500);

  String get _key => 'unread_v1:$_userId';

  Future<Map<String, int>> load() async {
    if (_userId.isEmpty) return const {};
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return const {};
      final decoded = json.decode(raw);
      if (decoded is! Map) return const {};
      return {
        for (final entry in decoded.entries)
          entry.key.toString(): (entry.value as num?)?.toInt() ?? 0,
      };
    } catch (e) {
      debugPrint('[unread] load failed: $e');
      return const {};
    }
  }

  /// Debounced write. Multiple `save()` calls within [_writeDelay] collapse
  /// into a single disk write of the last snapshot.
  void save(Map<String, int> counts) {
    if (_userId.isEmpty) return;
    _writeDebounce?.cancel();
    _writeDebounce = Timer(_writeDelay, () async {
      try {
        final prefs = await SharedPreferences.getInstance();
        // Drop 0-value entries to keep payload compact.
        final pruned = {
          for (final entry in counts.entries)
            if (entry.value > 0) entry.key: entry.value,
        };
        if (pruned.isEmpty) {
          await prefs.remove(_key);
        } else {
          await prefs.setString(_key, json.encode(pruned));
        }
      } catch (e) {
        debugPrint('[unread] save failed: $e');
      }
    });
  }

  static Future<void> clearForUser(String userId) async {
    if (userId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('unread_v1:$userId');
    } catch (e) {
      debugPrint('[unread] clear failed: $e');
    }
  }

  void dispose() {
    _writeDebounce?.cancel();
    _writeDebounce = null;
  }
}
