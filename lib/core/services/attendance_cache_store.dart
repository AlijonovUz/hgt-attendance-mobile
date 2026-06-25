import 'dart:convert';

import '../../features/attendance/data/models/attendance_event_model.dart';
import '../../features/attendance/data/models/personal_stats_model.dart';
import '../../features/attendance/domain/entities/attendance_event.dart';
import '../../features/attendance/domain/entities/attendance_stats.dart';
import '../constants/storage_keys.dart';
import 'storage_service.dart';

/// Davomat ma’lumotlarini offline ko‘rsatish uchun keshlaydi (JSON,
/// `StorageService`). Uch xil ma’lumot:
/// - **bugungi yozuvlar** (`cachedTodayEvents`) — sana+userId bilan, faqat shu
///   kun va shu user uchun amal qiladi (kun o‘zgarsa eskirgan deb tashlanadi);
/// - **sana-oralig‘i yozuvlari** (`cachedRangeEvents`) — key→events map;
/// - **shaxsiy statistika** (`cachedPersonalStats`) — key→stats map.
///
/// Map’lar [_maxEntries] bilan cheklanadi (eng eskisi tushib qoladi) — kesh
/// cheksiz o‘smaydi. Online so‘rov muvaffaqiyatida yoziladi; offline’da
/// repository shu yerdan o‘qiydi.
class AttendanceCacheStore {
  AttendanceCacheStore(this._storage);

  final StorageService _storage;

  static const int _maxEntries = 16;

  // ---- Bugungi yozuvlar ----------------------------------------------------

  Future<void> writeToday(String userId, List<AttendanceEvent> events) async {
    final payload = {
      'date': _dayKey(DateTime.now()),
      'user_id': userId,
      'events': [
        for (final e in events) AttendanceEventModel.fromEntity(e).toJson(),
      ],
    };
    await _storage.setString(StorageKeys.cachedTodayEvents, jsonEncode(payload));
  }

  /// Bugungi keshlangan yozuvlar — faqat shu user va shu kun bo‘lsa qaytadi.
  List<AttendanceEvent>? readToday(String userId) {
    final raw = _storage.getString(StorageKeys.cachedTodayEvents);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (map['user_id'] != userId) return null;
      if (map['date'] != _dayKey(DateTime.now())) return null; // eskirgan kun
      return _eventsFrom(map['events']);
    } catch (_) {
      return null;
    }
  }

  // ---- Sana-oralig‘i yozuvlari ---------------------------------------------

  Future<void> writeRange(
    String userId,
    DateTime start,
    DateTime end,
    List<AttendanceEvent> events,
  ) async {
    final map = _readMap(StorageKeys.cachedRangeEvents);
    map[_rangeKey(userId, start, end)] = [
      for (final e in events) AttendanceEventModel.fromEntity(e).toJson(),
    ];
    await _writeMap(StorageKeys.cachedRangeEvents, map);
  }

  List<AttendanceEvent>? readRange(
    String userId,
    DateTime start,
    DateTime end,
  ) {
    final map = _readMap(StorageKeys.cachedRangeEvents);
    final entry = map[_rangeKey(userId, start, end)];
    if (entry == null) return null;
    return _eventsFrom(entry);
  }

  // ---- Shaxsiy statistika ---------------------------------------------------

  Future<void> writePersonalStats(
    DateTime start,
    DateTime end,
    AttendanceStats stats,
  ) async {
    final map = _readMap(StorageKeys.cachedPersonalStats);
    map[_statsKey(start, end)] =
        PersonalStatsModel.fromEntity(stats).toJson();
    await _writeMap(StorageKeys.cachedPersonalStats, map);
  }

  AttendanceStats? readPersonalStats(DateTime start, DateTime end) {
    final map = _readMap(StorageKeys.cachedPersonalStats);
    final entry = map[_statsKey(start, end)];
    if (entry is! Map) return null;
    try {
      return PersonalStatsModel.fromJson(entry.cast<String, dynamic>())
          .toEntity();
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    await _storage.remove(StorageKeys.cachedTodayEvents);
    await _storage.remove(StorageKeys.cachedRangeEvents);
    await _storage.remove(StorageKeys.cachedPersonalStats);
  }

  // ---- Yordamchilar ---------------------------------------------------------

  List<AttendanceEvent> _eventsFrom(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) =>
            AttendanceEventModel.fromJson(e.cast<String, dynamic>()).toEntity())
        .toList();
  }

  Map<String, dynamic> _readMap(String key) {
    final raw = _storage.getString(key);
    if (raw == null || raw.isEmpty) return {};
    try {
      return (jsonDecode(raw) as Map).cast<String, dynamic>();
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeMap(String key, Map<String, dynamic> map) async {
    // Eng eski yozuvlarni tashlab, o‘lchamni cheklaymiz (insert tartibi saqlanadi).
    while (map.length > _maxEntries) {
      map.remove(map.keys.first);
    }
    await _storage.setString(key, jsonEncode(map));
  }

  String _dayKey(DateTime d) =>
      '${d.year}-${_two(d.month)}-${_two(d.day)}';

  String _rangeKey(String userId, DateTime start, DateTime end) =>
      '$userId|${_dayKey(start)}|${_dayKey(end)}';

  String _statsKey(DateTime start, DateTime end) =>
      '${_dayKey(start)}|${_dayKey(end)}';

  String _two(int n) => n.toString().padLeft(2, '0');
}
