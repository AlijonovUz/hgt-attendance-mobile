import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/attendance_event.dart';
import '../../domain/entities/attendance_event_type.dart';
import '../../domain/entities/attendance_stats.dart';
import '../../domain/repository/attendance_repository.dart';
import '../data_sources/attendance_remote_data_source.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  const AttendanceRepositoryImpl({required AttendanceRemoteDataSource remote})
    : _remote = remote;

  final AttendanceRemoteDataSource _remote;

  @override
  Future<void> mark({
    required AttendanceEventType eventType,
    required double latitude,
    required double longitude,
    required String imagePath,
  }) => _guard(
    () => _remote.mark(
      eventType: eventType,
      latitude: latitude,
      longitude: longitude,
      imagePath: imagePath,
    ),
  );

  @override
  Future<List<AttendanceEvent>> todayEvents({required String userId}) =>
      _guard(() async {
        final models = await _remote.getTodayEvents(userId: userId);
        return models.map((m) => m.toEntity()).toList();
      });

  @override
  Future<List<AttendanceEvent>> rangeEvents({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) => _guard(() async {
    final models = await _remote.getEvents(
      userId: userId,
      start: start,
      end: end,
    );
    return models.map((m) => m.toEntity()).toList();
  });

  @override
  Future<AttendanceStats> personalStats({
    required DateTime start,
    required DateTime end,
  }) => _guard(() async {
    final model = await _remote.getPersonalStats(start: start, end: end);
    return model.toEntity();
  });

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on ThrottleException catch (e) {
      throw ThrottleFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
