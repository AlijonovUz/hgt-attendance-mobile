import 'dart:convert';

import 'package:hive/hive.dart';

import '../../domain/entities/geozone.dart';
import '../../domain/entities/pending_attendance.dart';
import '../models/geozone_model.dart';
import '../models/pending_attendance_model.dart';

/// Hive boks nomlari (bootstrap’da ochiladi).
abstract final class AttendanceBoxes {
  /// Sinxron kutayotgan offline davomatlar (key = `localId`).
  static const pending = 'pending_attendance';

  /// Cache: geozone + reference embedding.
  static const cache = 'attendance_cache';
}

const _geozoneKey = 'geozone';
const _embeddingKey = 'ref_embedding';

/// Offline davomat lokal manbai — navbat + cache (geozone, yuz embeddingi).
///
/// Yozuvlar `Box<String>`da `jsonEncode` bilan saqlanadi (TypeAdapter yo‘q).
class AttendanceLocalDataSource {
  AttendanceLocalDataSource({
    required Box<String> pendingBox,
    required Box<String> cacheBox,
  })  : _pending = pendingBox,
        _cache = cacheBox;

  final Box<String> _pending;
  final Box<String> _cache;

  // ── Navbat ──────────────────────────────────────────────────────────────

  Future<void> enqueue(PendingAttendance item) =>
      _pending.put(item.localId, jsonEncode(PendingAttendanceMapper.toJson(item)));

  /// Navbatdagilar `enqueuedAt` bo‘yicha o‘sish tartibida (FIFO).
  List<PendingAttendance> pending() {
    final items = _pending.values
        .map((s) => PendingAttendanceMapper.fromJson(
            (jsonDecode(s) as Map).cast<String, dynamic>()))
        .toList()
      ..sort((a, b) => a.enqueuedAt.compareTo(b.enqueuedAt));
    return items;
  }

  int pendingCount() => _pending.length;

  Future<void> removePending(String localId) => _pending.delete(localId);

  Future<void> updateAttempts(PendingAttendance item) => enqueue(item);

  // ── Geozone cache ─────────────────────────────────────────────────────────

  Future<void> cacheGeozone(GeozoneModel geozone) =>
      _cache.put(_geozoneKey, jsonEncode(geozone.toJson()));

  Geozone? cachedGeozone() {
    final raw = _cache.get(_geozoneKey);
    if (raw == null) return null;
    return GeozoneModel.fromJson((jsonDecode(raw) as Map).cast<String, dynamic>())
        .toEntity();
  }

  // ── Reference embedding cache ───────────────────────────────────────────

  /// [key] = `profileId|faceImageUrl` (URL o‘zgarsa qayta hisoblanadi).
  Future<void> saveReferenceEmbedding(String key, List<double> vector) =>
      _cache.put(_embeddingKey, jsonEncode({'key': key, 'vector': vector}));

  ({String key, List<double> vector})? referenceEmbedding() {
    final raw = _cache.get(_embeddingKey);
    if (raw == null) return null;
    final map = (jsonDecode(raw) as Map).cast<String, dynamic>();
    final vector =
        (map['vector'] as List).map((e) => (e as num).toDouble()).toList();
    return (key: map['key']?.toString() ?? '', vector: vector);
  }

  Future<void> clearAll() async {
    await _pending.clear();
    await _cache.clear();
  }
}
