import 'dart:async';

import '../../app/bloc/session_bloc.dart';
import '../../features/attendance/domain/entities/attendance_event_type.dart';
import '../../features/attendance/domain/repository/attendance_repository.dart';
import '../error/failures.dart';
import 'connectivity_service.dart';
import 'logger_service.dart';
import 'offline_attendance_store.dart';

/// Offline davomat navbatini internet yonganida avtomatik yuboradi.
///
/// Tinglaydi: `connectivity_plus` (offline→online) + `SessionBloc`
/// (`authenticated`). Har bir navbat elementi `created_at` + `signature` bilan
/// `POST /v1/attendance/attendance/`ga yuboriladi. Natijaga qarab:
/// - 2xx → navbatdan o‘chiriladi (rasm ham).
/// - tarmoq/401/429 → navbatda qoladi (keyin qayta urinadi, drenaj to‘xtaydi).
/// - server (400 — imzo/eskirgan) → tashlanadi (qayta urinish foydasiz).
/// - 24 soatdan eski (doc cheklovi) → urinmasdan tashlanadi.
///
/// [changes] — drenajdan keyin ping (home pending-badge’ni yangilaydi).
class OfflineSyncService {
  OfflineSyncService({
    required OfflineAttendanceStore store,
    required AttendanceRepository repository,
    required ConnectivityService connectivity,
    required SessionBloc session,
    required LoggerService logger,
  })  : _store = store,
        _repository = repository,
        _connectivity = connectivity,
        _session = session,
        _logger = logger;

  final OfflineAttendanceStore _store;
  final AttendanceRepository _repository;
  final ConnectivityService _connectivity;
  final SessionBloc _session;
  final LoggerService _logger;

  static const Duration _maxAge = Duration(hours: 24);

  StreamSubscription<bool>? _connSub;
  StreamSubscription<SessionState>? _sessionSub;
  final StreamController<void> _changes = StreamController<void>.broadcast();
  bool _draining = false;

  /// Drenajdan keyin ping — UI pending sonini qayta o‘qiydi.
  Stream<void> get changes => _changes.stream;

  /// Listenerlarni ishga tushiradi va bir marta darhol sinxron qiladi.
  void start() {
    _connSub = _connectivity.onStatusChanged.listen((online) {
      if (online) syncNow();
    });
    _sessionSub = _session.stream.listen((s) {
      if (s.isAuthenticated) syncNow();
    });
    syncNow();
  }

  Future<int> pendingCount() => _store.count();

  /// Navbatni drenaj qiladi. Faqat authenticated + online holatda ishlaydi.
  Future<void> syncNow() async {
    if (_draining) return;
    if (!_session.state.isAuthenticated) return;
    _draining = true;
    try {
      if (!await _connectivity.isConnected()) return;
      final items = await _store.all();
      if (items.isEmpty) return;

      for (final item in items) {
        // 24 soatlik limit — urinmasdan tashlaymiz.
        if (_isExpired(item)) {
          _logger.log('Offline davomat eskirgan (24h+), tashlandi: ${item.id}');
          await _store.remove(item.id);
          continue;
        }
        final stop = await _send(item);
        if (stop) break; // tarmoq/401 — keyin qayta urinamiz.
      }
    } finally {
      _draining = false;
      if (!_changes.isClosed) _changes.add(null);
    }
  }

  /// Bitta elementni yuboradi. `true` qaytsa — drenajni to‘xtatish kerak
  /// (tarmoq/auth muammosi, navbatda qoladi).
  Future<bool> _send(PendingAttendance item) async {
    try {
      await _repository.mark(
        eventType: _eventTypeFrom(item.eventType),
        latitude: item.latitude,
        longitude: item.longitude,
        imagePath: item.imagePath,
        createdAt: item.createdAt,
        signature: item.signature,
      );
      await _store.remove(item.id);
      return false;
    } on NetworkFailure {
      return true; // internet uzildi — keyin davom etamiz.
    } on UnauthorizedFailure {
      return true; // token muammosi — keyin (refresh’dan keyin) urinamiz.
    } on ThrottleFailure {
      return true; // 429 — keyin urinamiz.
    } on ServerFailure catch (e) {
      // 400 (imzo/eskirgan/validatsiya) — qayta urinish foydasiz, tashlaymiz.
      _logger.log('Offline davomat rad etildi (${item.id}): ${e.message}');
      await _store.remove(item.id);
      return false;
    } catch (e) {
      _logger.log('Offline davomat xatosi (${item.id}): $e');
      return true;
    }
  }

  bool _isExpired(PendingAttendance item) {
    final queued = DateTime.tryParse(item.queuedAt);
    if (queued == null) return false;
    return DateTime.now().difference(queued) > _maxAge;
  }

  AttendanceEventType _eventTypeFrom(String apiValue) {
    return AttendanceEventType.values.firstWhere(
      (e) => e.apiValue == apiValue,
      orElse: () => AttendanceEventType.checkIn,
    );
  }

  Future<void> dispose() async {
    await _connSub?.cancel();
    await _sessionSub?.cancel();
    await _changes.close();
  }
}
