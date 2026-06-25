import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/offline_attendance_store.dart';
import '../../../../core/services/offline_sync_service.dart';
import '../../../attendance/domain/entities/attendance_event.dart' as ent;
import '../../../attendance/domain/entities/attendance_event_type.dart';
import '../../../attendance/domain/usecases/get_today_attendance_usecase.dart';
import 'attendance_step.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

/// Kunlik davomat holatini boshqaradi — manba **backend** (bugungi yozuvlar).
///
/// Bosqichlar profil schedule’idan keladi ([AttendanceConfigured]); belgilangan
/// (yuz-tekshiruvdan o‘tgan, `face_verify: true`) yozuvlar haqiqiy vaqt + halqa
/// boshlanish nuqtasini beradi. Har yuz-tekshiruvdan keyin [AttendanceRefreshed]
/// qayta yuklaydi.
class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  AttendanceBloc({
    required GetTodayAttendanceUseCase getToday,
    required OfflineAttendanceStore offlineStore,
    required OfflineSyncService syncService,
  })  : _getToday = getToday,
        _offlineStore = offlineStore,
        _syncService = syncService,
        super(const AttendanceState()) {
    on<AttendanceConfigured>(_onConfigured);
    on<AttendanceRefreshed>(_onRefreshed);
    // Navbat drenaj qilingach (offline→online) holatni qayta yuklaymiz.
    _syncSub = _syncService.changes.listen((_) {
      if (!isClosed) add(const AttendanceRefreshed());
    });
  }

  final GetTodayAttendanceUseCase _getToday;
  final OfflineAttendanceStore _offlineStore;
  final OfflineSyncService _syncService;
  StreamSubscription<void>? _syncSub;
  String? _userId;

  @override
  Future<void> close() async {
    await _syncSub?.cancel();
    return super.close();
  }

  Future<void> _onConfigured(AttendanceConfigured event, Emitter<AttendanceState> emit) async {
    _userId = event.userId;
    final steps = event.steps.isEmpty ? kAllSteps : event.steps;
    emit(state.copyWith(steps: steps));
    await _load(emit);
  }

  Future<void> _onRefreshed(AttendanceRefreshed event, Emitter<AttendanceState> emit) => _load(emit);

  /// Bugungi yozuvlarni olib, holatni qayta quradi (xatoda eski holat qoladi).
  /// Backend GET muvaffaqiyatsiz bo‘lsa (offline) — bo‘sh ro‘yxat bilan davom
  /// etib, lokal navbatni baribir qo‘shamiz (offline davomat ham ko‘rinadi).
  Future<void> _load(Emitter<AttendanceState> emit) async {
    final uid = _userId;
    if (uid == null || uid.isEmpty) return;
    try {
      var events = const <ent.AttendanceEvent>[];
      try {
        events = await _getToday(GetTodayAttendanceParams(userId: uid));
      } on Failure {
        // Offline — backend yozuvlari yo‘q, faqat lokal navbatdan quramiz.
      }

      final recorded = <AttendanceStep, String>{};
      DateTime? arrival;
      DateTime? departure;
      DateTime? lunchOut;
      DateTime? lunchIn;
      for (final ev in events) {
        if (!ev.faceVerify) continue; // faqat tasdiqlangan yozuvlar
        final step = stepForEventType(ev.eventType);
        if (step == null) continue;
        final local = ev.createdAt.toLocal();
        recorded.putIfAbsent(step, () => _fmt(local));
        switch (step) {
          case AttendanceStep.arrive:
            arrival ??= local;
          case AttendanceStep.lunchOut:
            lunchOut ??= local;
          case AttendanceStep.lunchIn:
            lunchIn ??= local;
          case AttendanceStep.leave:
            departure ??= local;
          case AttendanceStep.done:
            break;
        }
      }

      // Offline navbatdagi (hali yuborilmagan) yozuvlarni optimistik qo‘shamiz —
      // halqa/bosqich sinxrongacha ham oldinga siljiydi.
      final pending = await _offlineStore.all();
      var pendingCount = 0;
      for (final p in pending) {
        pendingCount++;
        final step = stepForEventType(
          AttendanceEventType.fromApi(p.eventType),
        );
        if (step == null) continue;
        final local = DateTime.tryParse(p.createdAt)?.toLocal();
        if (local == null) continue;
        recorded.putIfAbsent(step, () => _fmt(local));
        switch (step) {
          case AttendanceStep.arrive:
            arrival ??= local;
          case AttendanceStep.lunchOut:
            lunchOut ??= local;
          case AttendanceStep.lunchIn:
            lunchIn ??= local;
          case AttendanceStep.leave:
            departure ??= local;
          case AttendanceStep.done:
            break;
        }
      }

      final current = state.steps.firstWhere((s) => !recorded.containsKey(s), orElse: () => AttendanceStep.done);

      emit(
        state.copyWith(
          current: current,
          recorded: recorded,
          arrivalAt: arrival ?? state.arrivalAt,
          departureAt: departure ?? state.departureAt,
          lunchOutAt: lunchOut ?? state.lunchOutAt,
          lunchInAt: lunchIn ?? state.lunchInAt,
          pendingCount: pendingCount,
        ),
      );
    } on Failure {
      // Tarmoq/server xatosi — joriy holatni saqlaymiz.
    }
  }

  static String _fmt(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
  }
}
