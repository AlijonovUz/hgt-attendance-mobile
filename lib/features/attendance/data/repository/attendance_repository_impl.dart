import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/attendance_cache_store.dart';
import '../../domain/entities/attendance_event.dart';
import '../../domain/entities/attendance_event_type.dart';
import '../../domain/entities/attendance_stats.dart';
import '../../domain/repository/attendance_repository.dart';
import '../data_sources/attendance_remote_data_source.dart';

/// Cache-aside: online so‘rov muvaffaqiyatida natija keshga yoziladi; internet
/// yo‘qligida ([NetworkException]) keshdagi ma’lumot qaytariladi (bo‘lsa).
/// `mark` keshlanmaydi — u offline’da [OfflineSyncService] navbati orqali ketadi.
class AttendanceRepositoryImpl implements AttendanceRepository {
  const AttendanceRepositoryImpl({
    required AttendanceRemoteDataSource remote,
    required AttendanceCacheStore cache,
  })  : _remote = remote,
        _cache = cache;

  final AttendanceRemoteDataSource _remote;
  final AttendanceCacheStore _cache;

  @override
  Future<void> mark({
    required AttendanceEventType eventType,
    required double latitude,
    required double longitude,
    required String imagePath,
    String? createdAt,
    String? signature,
  }) => _guard(
    () => _remote.mark(
      eventType: eventType,
      latitude: latitude,
      longitude: longitude,
      imagePath: imagePath,
      createdAt: createdAt,
      signature: signature,
    ),
  );

  @override
  Future<List<AttendanceEvent>> todayEvents({required String userId}) async {
    try {
      final events = (await _remote.getTodayEvents(userId: userId))
          .map((m) => m.toEntity())
          .toList();
      await _cache.writeToday(userId, events);
      return events;
    } on NetworkException catch (e) {
      final cached = _cache.readToday(userId);
      if (cached != null) return cached;
      throw NetworkFailure(e.message);
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on ThrottleException catch (e) {
      throw ThrottleFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<List<AttendanceEvent>> rangeEvents({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final events = (await _remote.getEvents(
        userId: userId,
        start: start,
        end: end,
      )).map((m) => m.toEntity()).toList();
      await _cache.writeRange(userId, start, end, events);
      return events;
    } on NetworkException catch (e) {
      final cached = _cache.readRange(userId, start, end);
      if (cached != null) return cached;
      throw NetworkFailure(e.message);
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on ThrottleException catch (e) {
      throw ThrottleFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<AttendanceStats> personalStats({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final stats =
          (await _remote.getPersonalStats(start: start, end: end)).toEntity();
      await _cache.writePersonalStats(start, end, stats);
      return stats;
    } on NetworkException catch (e) {
      final cached = _cache.readPersonalStats(start, end);
      if (cached != null) return cached;
      throw NetworkFailure(e.message);
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on ThrottleException catch (e) {
      throw ThrottleFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

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
