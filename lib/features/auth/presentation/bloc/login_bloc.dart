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

  void _onFullNameChanged(
    LoginFullNameChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(
      state.copyWith(
        fullName: event.value,
        status: LoginStatus.initial,
        errorKind: LoginErrorKind.none,
        clearError: true,
      ),
    );
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(
      state.copyWith(
        password: event.value,
        status: LoginStatus.initial,
        errorKind: LoginErrorKind.none,
        clearError: true,
      ),
    );
  }

  void _onObscureToggled(LoginObscureToggled event, Emitter<LoginState> emit) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.canSubmit) return;

    emit(
      state.copyWith(
        status: LoginStatus.loading,
        errorKind: LoginErrorKind.none,
        clearError: true,
      ),
    );
    try {
      final AuthTokens tokens = await _loginUseCase(
        LoginParams(fullName: state.fullName.trim(), password: state.password),
      );
      emit(
        state.copyWith(
          status: LoginStatus.success,
          accessToken: tokens.access,
          refreshToken: tokens.refresh,
          faceImage: tokens.faceImage,
          responseFullName: tokens.fullName,
          isPasswordChanged: tokens.isPasswordChanged,
          offlineSecret: tokens.offlineSecret,
        ),
      );
    } on Failure catch (failure) {
      _emitFailure(failure, emit);
    } catch (_) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorKind: LoginErrorKind.server,
        ),
      );
    }
  }

  void _emitFailure(Failure failure, Emitter<LoginState> emit) {
    switch (failure) {
      case NetworkFailure():
        emit(
          state.copyWith(
            status: LoginStatus.failure,
            errorKind: LoginErrorKind.network,
          ),
        );
      case ThrottleFailure(
        :final retryAfterSeconds,
        :final attemptsLeft,
        :final message,
      ):
        // Backend bloklaydi va `retry_after_seconds` yuboradi — shu vaqtni
        // olib ortga sanaymiz; ko‘rinadigan matn mobil l10n’dan.
        final seconds = retryAfterSeconds ?? _parseBlockSeconds(message);
        emit(
          state.copyWith(
            status: LoginStatus.failure,
            errorKind: LoginErrorKind.blocked,
            blockedSeconds: seconds,
            blockedTotalSeconds: seconds,
            attemptsLeft: attemptsLeft ?? 0,
            clearError: true,
          ),
        );
        _startBlockTimer(seconds);
      case UnauthorizedFailure(:final attemptsLeft, :final message):
        // Qolgan urinishlar backend `attempts_left`dan olinadi (yo‘q bo‘lsa
        // joriy qiymatdan bittaga kamaytiriladi). Backend `errorMsg`i bo‘lsa
        // to‘g‘ridan-to‘g‘ri ko‘rsatiladi (aks holda widget l10n fallback’i).
        final msg = _isGeneric(message) ? null : message;
        emit(
          state.copyWith(
            status: LoginStatus.failure,
            errorKind: LoginErrorKind.invalid,
            attemptsLeft: attemptsLeft ?? (state.attemptsLeft - 1),
            errorText: msg,
            clearError: msg == null,
          ),
        );
      default:
        emit(
          state.copyWith(
            status: LoginStatus.failure,
            errorKind: LoginErrorKind.server,
            errorText: _isGeneric(failure.message) ? null : failure.message,
          ),
        );
    }
  }

  void _onBlockTicked(LoginBlockTicked event, Emitter<LoginState> emit) {
    final next = state.blockedSeconds - 1;
    if (next <= 0) {
      _blockTimer?.cancel();
      // Blok tugadi → urinishlar yangidan to‘liq (maxAttempts) tiklanadi.
      emit(
        state.copyWith(
          status: LoginStatus.initial,
          errorKind: LoginErrorKind.none,
          blockedSeconds: 0,
          blockedTotalSeconds: 0,
          attemptsLeft: LoginState.maxAttempts,
          clearError: true,
        ),
      );
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
    final isMinutes =
        lower.contains('daqiqa') ||
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
