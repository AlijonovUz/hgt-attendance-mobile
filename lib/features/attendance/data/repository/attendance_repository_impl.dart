import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/attendance_event.dart';
import '../../domain/entities/attendance_event_type.dart';
import '../../domain/entities/pending_attendance.dart';
import '../../domain/repository/attendance_repository.dart';
import '../data_sources/attendance_local_data_source.dart';
import '../data_sources/attendance_remote_data_source.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  const AttendanceRepositoryImpl({
    required AttendanceRemoteDataSource remote,
    required AttendanceLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  final AttendanceRemoteDataSource _remote;
  final AttendanceLocalDataSource _local;

  @override
  Future<void> mark({
    required AttendanceEventType eventType,
    required double latitude,
    required double longitude,
    required String imagePath,
    String? createdAtIso,
    String? signature,
  }) =>
      _guard(
        () => _remote.mark(
          eventType: eventType,
          latitude: latitude,
          longitude: longitude,
          imagePath: imagePath,
          createdAtIso: createdAtIso,
          signature: signature,
        ),
      );

  @override
  Future<List<AttendanceEvent>> todayEvents({required String userId}) =>
      _guard(() async {
        final models = await _remote.getTodayEvents(userId: userId);
        return models.map((m) => m.toEntity()).toList();
      });

  // ── Offline navbat ────────────────────────────────────────────────────────

  @override
  Future<void> enqueue(PendingAttendance item) => _local.enqueue(item);

  @override
  List<PendingAttendance> pending() => _local.pending();

  @override
  int pendingCount() => _local.pendingCount();

  @override
  Future<void> removePending(String localId) => _local.removePending(localId);

  @override
  Future<void> incrementAttempt(PendingAttendance item) =>
      _local.updateAttempts(item.copyWith(attempts: item.attempts + 1));

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on ThrottleException catch (e) {
      throw ThrottleFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ValidationException catch (e) {
      throw ValidationFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
