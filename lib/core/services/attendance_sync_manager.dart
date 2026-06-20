import 'dart:async';

import '../../app/bloc/session_bloc.dart';
import '../../features/attendance/domain/usecases/sync_pending_attendance_usecase.dart';
import 'connectivity_service.dart';
import 'logger_service.dart';

/// Offline davomat navbatini avtomatik sinxronlaydi.
///
/// Tarmoq tiklanganda **va** foydalanuvchi authenticated bo‘lganda
/// [SyncPendingAttendanceUseCase] ishga tushadi. Bir vaqtda bitta flush
/// ([_running] guard). App ishga tushganда bir marta urinadi.
class AttendanceSyncManager {
  AttendanceSyncManager({
    required ConnectivityService connectivity,
    required SyncPendingAttendanceUseCase sync,
    required SessionBloc session,
    required LoggerService logger,
  })  : _connectivity = connectivity,
        _sync = sync,
        _session = session,
        _logger = logger;

  final ConnectivityService _connectivity;
  final SyncPendingAttendanceUseCase _sync;
  final SessionBloc _session;
  final LoggerService _logger;

  StreamSubscription<bool>? _connSub;
  StreamSubscription<SessionState>? _sessionSub;
  bool _running = false;
  bool _started = false;

  /// Kuzatuvni boshlaydi (bir marta). Bootstrap’dan keyin chaqiriladi.
  void start() {
    if (_started) return;
    _started = true;
    _connSub = _connectivity.onStatusChange.listen((online) {
      if (online) unawaited(flush());
    });
    _sessionSub = _session.stream.listen((state) {
      if (state.isAuthenticated) unawaited(flush());
    });
    unawaited(flush());
  }

  /// Navbatni sinxron qiladi (authenticated + online bo‘lsa).
  Future<void> flush() async {
    if (_running) return;
    if (!_session.state.isAuthenticated) return;
    if (!await _connectivity.isConnected()) return;
    _running = true;
    try {
      final synced = await _sync();
      if (synced > 0) _logger.log('Offline davomat sinxron: $synced');
    } catch (e) {
      _logger.log('Offline davomat sinxron xatosi: $e');
    } finally {
      _running = false;
    }
  }

  Future<void> dispose() async {
    await _connSub?.cancel();
    await _sessionSub?.cancel();
  }
}
