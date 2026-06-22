import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/attendance_event.dart';
import '../repository/attendance_repository.dart';

/// Sana oralig‘idagi davomat yozuvlarini olish (tarix).
class GetAttendanceHistoryUseCase
    implements UseCase<List<AttendanceEvent>, GetAttendanceHistoryParams> {
  const GetAttendanceHistoryUseCase(this._repository);

  final AttendanceRepository _repository;

  @override
  Future<List<AttendanceEvent>> call(GetAttendanceHistoryParams params) =>
      _repository.rangeEvents(
        userId: params.userId,
        start: params.start,
        end: params.end,
      );
}

class GetAttendanceHistoryParams extends Equatable {
  const GetAttendanceHistoryParams({
    required this.userId,
    required this.start,
    required this.end,
  });

  final String userId;
  final DateTime start;
  final DateTime end;

  @override
  List<Object?> get props => [userId, start, end];
}
