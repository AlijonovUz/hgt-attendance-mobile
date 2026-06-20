import 'dart:io';

import '../../../../core/error/failures.dart';
import '../entities/pending_attendance.dart';
import '../repository/attendance_repository.dart';

/// Offline navbatni serverga sinxronlaydi (FIFO).
///
/// Har bir yozuv `created_at` + `signature` bilan yuboriladi:
/// - `2xx` → navbatdan o‘chiriladi + selfie fayl o‘chiriladi.
/// - `4xx` ([ValidationFailure], mas. imzo mos emas / vaqt eskirgan) → o‘chiriladi
///   (retry foydasiz).
/// - `401` ([UnauthorizedFailure]) → to‘xtatiladi (token muammosi, keyinroq).
/// - network/`5xx` → urinish oshiriladi va to‘xtatiladi (offline bo‘lsa
///   keyingilar ham muvaffaqiyatsiz). Keyingi connectivity hodisasida qayta.
///
/// 24 soatdan oshган yozuvlar (backend rad etadi) yuborilmasdan tashlanadi.
class SyncPendingAttendanceUseCase {
  const SyncPendingAttendanceUseCase(this._repository);

  final AttendanceRepository _repository;

  static const _maxAge = Duration(hours: 24);

  /// Sinxron qilingan yozuvlar sonini qaytaradi.
  Future<int> call() async {
    final items = _repository.pending();
    var synced = 0;

    for (final item in items) {
      if (DateTime.now().difference(item.enqueuedAt) >= _maxAge) {
        await _drop(item);
        continue;
      }
      try {
        await _repository.mark(
          eventType: item.eventType,
          latitude: item.latitude,
          longitude: item.longitude,
          imagePath: item.imagePath,
          createdAtIso: item.createdAtIso,
          signature: item.signature,
        );
        await _drop(item);
        synced++;
      } on ValidationFailure {
        await _drop(item);
      } on UnauthorizedFailure {
        break;
      } on Failure {
        await _repository.incrementAttempt(item);
        break;
      }
    }
    return synced;
  }

  Future<void> _drop(PendingAttendance item) async {
    await _repository.removePending(item.localId);
    try {
      final file = File(item.imagePath);
      if (file.existsSync()) await file.delete();
    } catch (_) {
      // Fayl o‘chmasa ham — yozuv navbatdan ketdi.
    }
  }
}
