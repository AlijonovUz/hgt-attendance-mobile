part of 'attendance_bloc.dart';

class AttendanceState extends Equatable {
  const AttendanceState({
    this.steps = kAllSteps,
    this.current = AttendanceStep.arrive,
    this.recorded = const {},
    this.arrivalAt,
    this.departureAt,
    this.lunchOutAt,
    this.lunchInAt,
  });

  /// Faol bosqichlar (profil schedule’iga mos, tartiblangan).
  final List<AttendanceStep> steps;

  /// Hozir surilishi kerak bo‘lgan bosqich (`done` — barchasi tugadi).
  final AttendanceStep current;

  /// Surib belgilangan haqiqiy vaqtlar (bosqich → HH:MM:SS).
  final Map<AttendanceStep, String> recorded;

  /// «Ishga keldim» (check_in) belgilangan daqiqa — halqa boshlanish nuqtasi.
  final DateTime? arrivalAt;

  /// «Ishdan ketdim» (check_out) belgilangan daqiqa — ishlagan vaqt tugashi.
  final DateTime? departureAt;

  /// «Tushlikka chiqdim» / «Tushlikdan qaytdim» daqiqalari — ishlagan vaqtdan
  /// tushlik tanaffusini chiqarib tashlash uchun.
  final DateTime? lunchOutAt;
  final DateTime? lunchInAt;

  bool get isComplete => current == AttendanceStep.done;

  /// Belgilangan (haqiqiy) vaqt — yo‘q bo‘lsa null (widget schedule’dan oladi).
  String? recordedTime(AttendanceStep step) => recorded[step];

  bool isDone(AttendanceStep step) => recorded.containsKey(step);

  AttendanceState copyWith({
    List<AttendanceStep>? steps,
    AttendanceStep? current,
    Map<AttendanceStep, String>? recorded,
    DateTime? arrivalAt,
    DateTime? departureAt,
    DateTime? lunchOutAt,
    DateTime? lunchInAt,
  }) => AttendanceState(
    steps: steps ?? this.steps,
    current: current ?? this.current,
    recorded: recorded ?? this.recorded,
    arrivalAt: arrivalAt ?? this.arrivalAt,
    departureAt: departureAt ?? this.departureAt,
    lunchOutAt: lunchOutAt ?? this.lunchOutAt,
    lunchInAt: lunchInAt ?? this.lunchInAt,
  );

  @override
  List<Object?> get props => [
    steps,
    current,
    recorded,
    arrivalAt,
    departureAt,
    lunchOutAt,
    lunchInAt,
  ];
}
