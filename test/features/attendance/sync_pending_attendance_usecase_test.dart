import 'package:flutter_test/flutter_test.dart';
import 'package:hgt_attendance_mobile/core/error/failures.dart';
import 'package:hgt_attendance_mobile/features/attendance/domain/entities/attendance_event.dart';
import 'package:hgt_attendance_mobile/features/attendance/domain/entities/attendance_event_type.dart';
import 'package:hgt_attendance_mobile/features/attendance/domain/entities/pending_attendance.dart';
import 'package:hgt_attendance_mobile/features/attendance/domain/repository/attendance_repository.dart';
import 'package:hgt_attendance_mobile/features/attendance/domain/usecases/sync_pending_attendance_usecase.dart';

/// In-memory fake — `mark` natijasini `markResults` orqali boshqaramiz.
class _FakeRepo implements AttendanceRepository {
  _FakeRepo(this._queue);

  final List<PendingAttendance> _queue;

  /// localId → tashlanadigan Failure (null = muvaffaqiyat).
  final Map<String, Failure?> markResults = {};
  final List<String> marked = [];

  @override
  Future<void> mark({
    required AttendanceEventType eventType,
    required double latitude,
    required double longitude,
    required String imagePath,
    String? createdAtIso,
    String? signature,
  }) async {
    // imagePath = localId (testda).
    marked.add(imagePath);
    final failure = markResults[imagePath];
    if (failure != null) throw failure;
  }

  @override
  List<PendingAttendance> pending() =>
      List.of(_queue)..sort((a, b) => a.enqueuedAt.compareTo(b.enqueuedAt));

  @override
  int pendingCount() => _queue.length;

  @override
  Future<void> removePending(String localId) =>
      Future.sync(() => _queue.removeWhere((e) => e.localId == localId));

  @override
  Future<void> incrementAttempt(PendingAttendance item) async {
    final i = _queue.indexWhere((e) => e.localId == item.localId);
    if (i >= 0) _queue[i] = _queue[i].copyWith(attempts: _queue[i].attempts + 1);
  }

  @override
  Future<void> enqueue(PendingAttendance item) async => _queue.add(item);

  @override
  Future<List<AttendanceEvent>> todayEvents({required String userId}) async => [];
}

PendingAttendance _item(String id, {DateTime? at}) => PendingAttendance(
      localId: id,
      eventType: AttendanceEventType.checkIn,
      latitude: 41,
      longitude: 69,
      createdAtIso: '2026-06-17T08:30:00+05:00',
      signature: 'sig',
      imagePath: id, // testda localId bilan bir xil
      enqueuedAt: at ?? DateTime.now(),
    );

void main() {
  group('SyncPendingAttendanceUseCase', () {
    test('2xx → barchasi yuboriladi va navbatdan o‘chadi', () async {
      final queue = [_item('a'), _item('b')];
      final repo = _FakeRepo(queue);
      final synced = await SyncPendingAttendanceUseCase(repo)();
      expect(synced, 2);
      expect(queue, isEmpty);
      expect(repo.marked, ['a', 'b']);
    });

    test('FIFO — enqueuedAt bo‘yicha tartib', () async {
      final old = _item('old', at: DateTime(2026, 6, 17, 8));
      final newer = _item('new', at: DateTime(2026, 6, 17, 9));
      final repo = _FakeRepo([newer, old]);
      await SyncPendingAttendanceUseCase(repo)();
      expect(repo.marked, ['old', 'new']);
    });

    test('ValidationFailure (400) → tashlanadi (retry yo‘q)', () async {
      final queue = [_item('bad'), _item('ok')];
      final repo = _FakeRepo(queue)
        ..markResults['bad'] = const ValidationFailure();
      final synced = await SyncPendingAttendanceUseCase(repo)();
      expect(synced, 1); // faqat 'ok'
      expect(queue, isEmpty); // ikkalasi ham navbatdan ketdi
    });

    test('NetworkFailure → qoladi, urinish oshadi, to‘xtaydi', () async {
      final queue = [_item('x'), _item('y')];
      final repo = _FakeRepo(queue)
        ..markResults['x'] = const NetworkFailure();
      final synced = await SyncPendingAttendanceUseCase(repo)();
      expect(synced, 0);
      expect(queue.length, 2); // hech narsa o‘chmadi
      expect(queue.first.attempts, 1); // 'x' urinishi oshdi
      expect(repo.marked, ['x']); // 'y'ga yetmadi (to‘xtadi)
    });

    test('24 soatdan eski → yuborilmasdan tashlanadi', () async {
      final stale = _item('stale', at: DateTime.now().subtract(const Duration(hours: 25)));
      final queue = [stale];
      final repo = _FakeRepo(queue);
      final synced = await SyncPendingAttendanceUseCase(repo)();
      expect(synced, 0);
      expect(queue, isEmpty);
      expect(repo.marked, isEmpty); // yuborilmadi
    });
  });
}
