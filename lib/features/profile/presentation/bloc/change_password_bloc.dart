import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../onboarding/domain/entities/password_rule.dart';
import '../../../onboarding/domain/usecases/change_password_usecase.dart';

part 'change_password_event.dart';
part 'change_password_state.dart';

/// «Parol o‘zgartirish» sahifasi holatini boshqaradi (Figma 551‑15732).
///
/// Onboarding parol bosqichi bilan bir xil shartlar (jonli ro‘yxat) + bir xil
/// `change-password` backend (`ChangePasswordUseCase`). Bu yerda token allaqachon
/// saqlangan (uy ekrani) — `accessToken` berilmaydi, `AuthInterceptor` biriktiradi.
/// Bloc context-free: xato enumlarini emit qiladi, lokalizatsiya widgetda.
class ChangePasswordBloc extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  ChangePasswordBloc({required ChangePasswordUseCase changePassword})
    : _changePassword = changePassword,
      super(const ChangePasswordState()) {
    on<ChangePasswordOldChanged>(_onOldChanged);
    on<ChangePasswordNewChanged>(_onNewChanged);
    on<ChangePasswordConfirmChanged>(_onConfirmChanged);
    on<ChangePasswordSubmitted>(_onSubmitted);
  }

  final ChangePasswordUseCase _changePassword;

  void _onOldChanged(
    ChangePasswordOldChanged event,
    Emitter<ChangePasswordState> emit,
  ) {
    emit(state.copyWith(
      oldPassword: event.value,
      error: ChangePasswordErrorKind.none,
    ));
  }

  void _onNewChanged(
    ChangePasswordNewChanged event,
    Emitter<ChangePasswordState> emit,
  ) {
    emit(state.copyWith(
      newPassword: event.value,
      error: ChangePasswordErrorKind.none,
    ));
  }

  void _onConfirmChanged(
    ChangePasswordConfirmChanged event,
    Emitter<ChangePasswordState> emit,
  ) {
    emit(state.copyWith(
      confirmPassword: event.value,
      error: ChangePasswordErrorKind.none,
    ));
  }

  Future<void> _onSubmitted(
    ChangePasswordSubmitted event,
    Emitter<ChangePasswordState> emit,
  ) async {
    if (!state.canSubmit) return;
    emit(state.copyWith(
      submitting: true,
      error: ChangePasswordErrorKind.none,
    ));
    try {
      await _changePassword(
        ChangePasswordParams(
          oldPassword: state.oldPassword,
          newPassword: state.newPassword,
          confirmNewPassword: state.confirmPassword,
        ),
      );
      emit(state.copyWith(submitting: false, success: true));
    } on Failure catch (failure) {
      emit(state.copyWith(
        submitting: false,
        error: failure is NetworkFailure
            ? ChangePasswordErrorKind.network
            : ChangePasswordErrorKind.server,
      ));
    } catch (_) {
      emit(state.copyWith(
        submitting: false,
        error: ChangePasswordErrorKind.server,
      ));
    }
  }
}
