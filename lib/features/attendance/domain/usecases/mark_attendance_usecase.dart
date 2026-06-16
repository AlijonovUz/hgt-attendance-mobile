import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/attendance_event_type.dart';
import '../repository/attendance_repository.dart';

/// Davomat hodisasini belgilash (selfie + GPS bilan).
class MarkAttendanceUseCase implements UseCase<void, MarkAttendanceParams> {
  const MarkAttendanceUseCase(this._repository);

  final AttendanceRepository _repository;

  @override
  Future<void> call(MarkAttendanceParams params) => _repository.mark(
    eventType: params.eventType,
    latitude: params.latitude,
    longitude: params.longitude,
    imagePath: params.imagePath,
  );
}

class MarkAttendanceParams extends Equatable {
  const MarkAttendanceParams({
    required this.eventType,
    required this.latitude,
    required this.longitude,
    required this.imagePath,
  });

  final AttendanceEventType eventType;
  final double latitude;
  final double longitude;
  final String imagePath;

  @override
  List<Object?> get props => [eventType, latitude, longitude, imagePath];
}
