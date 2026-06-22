import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/attendance_stats.dart';
import '../repository/attendance_repository.dart';

/// Sana oralig‘i bo‘yicha shaxsiy davomat statistikasini olish.
class GetPersonalStatsUseCase
    implements UseCase<AttendanceStats, GetPersonalStatsParams> {
  const GetPersonalStatsUseCase(this._repository);

  final AttendanceRepository _repository;

  @override
  Future<AttendanceStats> call(GetPersonalStatsParams params) =>
      _repository.personalStats(start: params.start, end: params.end);
}

class GetPersonalStatsParams extends Equatable {
  const GetPersonalStatsParams({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  @override
  List<Object?> get props => [start, end];
}
