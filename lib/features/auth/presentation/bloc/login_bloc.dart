import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/usecases/login_usecase.dart';

part 'login_event.dart';
part 'login_state.dart';

/// Login ekrani holatini boshqaradi (events → states).
///
/// Bloc context-free: xato turini ([LoginErrorKind]) emit qiladi, lokalizatsiya
/// widget qatlamida bo‘ladi. Muvaffaqiyatda tokenlar emit qilinadi — navigatsiya
/// (`SessionBloc`) sahifadagi listener orqali. 429 (blok) holatida ichki MM:SS
/// sanagich (`Timer.periodic`) yuritiladi.
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required LoginUseCase loginUseCase})
      : _loginUseCase = loginUseCase,
        super(const LoginState()) {
    on<LoginFullNameChanged>(_onFullNameChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginObscureToggled>(_onObscureToggled);
    on<LoginSubmitted>(_onSubmitted);
    on<LoginBlockTicked>(_onBlockTicked);
  }

  final LoginUseCase _loginUseCase;
  Timer? _blockTimer;

  void _onFullNameChanged(LoginFullNameChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      fullName: event.value,
      status: LoginStatus.initial,
      errorKind: LoginErrorKind.none,
      clearError: true,
    ));
  }

  void _onPasswordChanged(LoginPasswordChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      password: event.value,
      status: LoginStatus.initial,
      errorKind: LoginErrorKind.none,
      clearError: true,
    ));
  }

  void _onObscureToggled(LoginObscureToggled event, Emitter<LoginState> emit) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.canSubmit) return;

    emit(state.copyWith(
      status: LoginStatus.loading,
      errorKind: LoginErrorKind.none,
      clearError: true,
    ));
    try {
      final AuthTokens tokens = await _loginUseCase(
        LoginParams(
          fullName: state.fullName.trim(),
          password: state.password,
        ),
      );
      emit(state.copyWith(
        status: LoginStatus.success,
        accessToken: tokens.access,
        refreshToken: tokens.refresh,
        faceImage: tokens.faceImage,
      ));
    } on Failure catch (failure) {
      _emitFailure(failure, emit);
    } catch (_) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorKind: LoginErrorKind.server,
      ));
    }
  }

  void _emitFailure(Failure failure, Emitter<LoginState> emit) {
    switch (failure) {
      case NetworkFailure():
        emit(state.copyWith(
          status: LoginStatus.failure,
          errorKind: LoginErrorKind.network,
        ));
      case ThrottleFailure():
        // 5-urinishdan keyin backend bloklaydi va qolgan vaqtni yuboradi —
        // faqat shu vaqtni olamiz, ko‘rinadigan matn mobil l10n’dan.
        final seconds = _parseBlockSeconds(failure.message);
        emit(state.copyWith(
          status: LoginStatus.failure,
          errorKind: LoginErrorKind.blocked,
          blockedSeconds: seconds,
          blockedTotalSeconds: seconds,
          failedAttempts: LoginState.maxAttempts,
          clearError: true,
        ));
        _startBlockTimer(seconds);
      case UnauthorizedFailure():
        // Har noto‘g‘ri urinish hisoblanadi — qolgan urinishlar matni mobil
        // tomonda hosil qilinadi (backend matni ishlatilmaydi).
        emit(state.copyWith(
          status: LoginStatus.failure,
          errorKind: LoginErrorKind.invalid,
          failedAttempts: state.failedAttempts + 1,
          clearError: true,
        ));
      default:
        emit(state.copyWith(
          status: LoginStatus.failure,
          errorKind: LoginErrorKind.server,
          errorText: _isGeneric(failure.message) ? null : failure.message,
        ));
    }
  }

  void _onBlockTicked(LoginBlockTicked event, Emitter<LoginState> emit) {
    final next = state.blockedSeconds - 1;
    if (next <= 0) {
      _blockTimer?.cancel();
      // Blok tugadi → urinishlar yangidan 5  taga tiklanadi.
      emit(state.copyWith(
        status: LoginStatus.initial,
        errorKind: LoginErrorKind.none,
        blockedSeconds: 0,
        blockedTotalSeconds: 0,
        failedAttempts: 0,
        clearError: true,
      ));
      return;
    }
    emit(state.copyWith(blockedSeconds: next));
  }

  void _startBlockTimer(int seconds) {
    _blockTimer?.cancel();
    if (seconds <= 0) return;
    _blockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const LoginBlockTicked()),
    );
  }

  /// 429 xabaridan qolgan vaqtni soniyada ajratadi. `MM:SS` yoki «N daqiqa» /
  /// «N soniya» ko‘rinishlarini qo‘llab-quvvatlaydi.
  static int _parseBlockSeconds(String message) {
    final clock = RegExp(r'(\d+):(\d{2})').firstMatch(message);
    if (clock != null) {
      final mm = int.tryParse(clock.group(1)!) ?? 0;
      final ss = int.tryParse(clock.group(2)!) ?? 0;
      return mm * 60 + ss;
    }
    final num = RegExp(r'\d+').firstMatch(message);
    if (num == null) return 0;
    final n = int.tryParse(num.group(0)!) ?? 0;
    final lower = message.toLowerCase();
    final isMinutes = lower.contains('daqiqa') ||
        lower.contains('минут') ||
        lower.contains('мин') ||
        lower.contains('min');
    return isMinutes ? n * 60 : n;
  }

  static bool _isGeneric(String message) {
    final m = message.trim().toLowerCase();
    return m.isEmpty ||
        m == 'unauthorized' ||
        m == 'server xatosi' ||
        m == 'server failure';
  }

  @override
  Future<void> close() {
    _blockTimer?.cancel();
    return super.close();
  }
}
