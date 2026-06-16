import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/attendance_event.dart';
import '../repository/attendance_repository.dart';

/// Bugungi davomat yozuvlarini olish (joriy foydalanuvchi).
class GetTodayAttendanceUseCase
    implements UseCase<List<AttendanceEvent>, GetTodayAttendanceParams> {
  const GetTodayAttendanceUseCase(this._repository);

  final AttendanceRepository _repository;

  @override
  Future<List<AttendanceEvent>> call(GetTodayAttendanceParams params) =>
      _repository.todayEvents(userId: params.userId);
}

class GetTodayAttendanceParams extends Equatable {
  const GetTodayAttendanceParams({required this.userId});
  final String userId;

  @override
  List<Object?> get props => [userId];
}
