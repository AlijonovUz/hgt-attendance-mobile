import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

/// Diskdagi (JSON) offline davomat navbatining bitta elementi.
class PendingAttendance {
  const PendingAttendance({
    required this.id,
    required this.eventType,
    required this.latitude,
    required this.longitude,
    required this.imagePath,
    required this.createdAt,
    required this.signature,
    required this.queuedAt,
  });

  /// Lokal noyob id (navbat kaliti + rasm fayl nomi).
  final String id;

  /// `event_type` api qiymati (`check_in`, `lunch_start`, ...).
  final String eventType;
  final double latitude;
  final double longitude;

  /// Doimiy joyga ko‘chirilgan selfie yo‘li.
  final String imagePath;

  /// Swipe vaqti — ISO8601 + offset (imzolangan).
  final String createdAt;

  /// `HMAC_SHA256(createdAt, offline_secret)`.
  final String signature;

  /// Navbatga qo‘yilgan vaqt (24 soatlik limitni hisoblash uchun).
  final String queuedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'event_type': eventType,
        'latitude': latitude,
        'longitude': longitude,
        'image_path': imagePath,
        'created_at': createdAt,
        'signature': signature,
        'queued_at': queuedAt,
      };

  factory PendingAttendance.fromJson(Map<String, dynamic> j) =>
      PendingAttendance(
        id: j['id']?.toString() ?? '',
        eventType: j['event_type']?.toString() ?? '',
        latitude: (j['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (j['longitude'] as num?)?.toDouble() ?? 0,
        imagePath: j['image_path']?.toString() ?? '',
        createdAt: j['created_at']?.toString() ?? '',
        signature: j['signature']?.toString() ?? '',
        queuedAt: j['queued_at']?.toString() ?? '',
      );
}

/// Offline davomat navbatini saqlaydi (JSON-fayl) va selfie’larni doimiy joyga
/// ko‘chiradi. Hive o‘rniga yengil yondashuv — navbat kichik (bir necha element).
///
/// Fayl: `<docs>/offline_attendance/queue.json`. Rasm:
/// `<docs>/offline_attendance/<id>.jpg`. Operatsiyalar ketma-ket: butun ro‘yxat
/// o‘qiladi → o‘zgartiriladi → qayta yoziladi (atomik, navbat kichik).
class OfflineAttendanceStore {
  OfflineAttendanceStore();

  static const _dirName = 'offline_attendance';
  static const _queueFile = 'queue.json';
  final _rand = Random();

  Future<Directory> _dir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}${Platform.pathSeparator}$_dirName');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<File> _file() async {
    final dir = await _dir();
    return File('${dir.path}${Platform.pathSeparator}$_queueFile');
  }

  /// Noyob id (vaqt + tasodif).
  String newId() =>
      '${DateTime.now().millisecondsSinceEpoch}_${_rand.nextInt(1 << 32)}';

  /// Selfie’ni doimiy joyga (`<docs>/offline_attendance/<id>.jpg`) ko‘chiradi va
  /// yangi yo‘lni qaytaradi.
  Future<String> persistImage(String sourcePath, String id) async {
    final dir = await _dir();
    final dest = '${dir.path}${Platform.pathSeparator}$id.jpg';
    await File(sourcePath).copy(dest);
    return dest;
  }

  Future<List<PendingAttendance>> all() async {
    final file = await _file();
    if (!await file.exists()) return [];
    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return [];
      final list = jsonDecode(raw) as List;
      return list
          .whereType<Map>()
          .map((e) => PendingAttendance.fromJson(e.cast<String, dynamic>()))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> enqueue(PendingAttendance item) async {
    final items = await all()
      ..add(item);
    await _writeAll(items);
  }

  /// Navbatdan elementni o‘chiradi va uning rasm faylini tozalaydi.
  Future<void> remove(String id) async {
    final items = await all();
    final remaining = items.where((e) => e.id != id).toList();
    final removed = items.where((e) => e.id == id);
    for (final r in removed) {
      try {
        final f = File(r.imagePath);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
    await _writeAll(remaining);
  }

  Future<int> count() async => (await all()).length;

  Future<void> _writeAll(List<PendingAttendance> items) async {
    final file = await _file();
    final data = jsonEncode([for (final e in items) e.toJson()]);
    await file.writeAsString(data, flush: true);
  }
}
