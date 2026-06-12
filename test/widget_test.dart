import 'package:flutter_test/flutter_test.dart';
import 'package:hgt_attendance_mobile/app/bloc/locale/locale_bloc.dart';
import 'package:hgt_attendance_mobile/app/bloc/session_bloc.dart';
import 'package:hgt_attendance_mobile/features/auth/presentation/bloc/login_bloc.dart';

void main() {
  group('SessionState', () {
    test('unknown is unresolved; others resolved', () {
      expect(const SessionState.unknown().isResolved, isFalse);
      expect(const SessionState.unauthenticated().isResolved, isTrue);
      expect(
        const SessionState.faceVerificationRequired().isFaceVerificationRequired,
        isTrue,
      );
      expect(const SessionState.authenticated().isAuthenticated, isTrue);
    });
  });

  group('LoginState', () {
    test('canSubmit requires both fields and not loading/blocked', () {
      const empty = LoginState();
      expect(empty.canSubmit, isFalse);

      const filled = LoginState(fullName: 'user', password: '1234');
      expect(filled.canSubmit, isTrue);

      const loading =
          LoginState(fullName: 'user', password: '1234', status: LoginStatus.loading);
      expect(loading.canSubmit, isFalse);

      const blocked = LoginState(
        fullName: 'user',
        password: '1234',
        errorKind: LoginErrorKind.blocked,
        blockedSeconds: 30,
      );
      expect(blocked.canSubmit, isFalse);
      expect(blocked.isBlocked, isTrue);
    });

    test('blockedClock formats MM:SS', () {
      expect(const LoginState(blockedSeconds: 885).blockedClock, '14:45');
      expect(const LoginState(blockedSeconds: 5).blockedClock, '00:05');
    });
  });

  group('AppLanguage', () {
    test('fromTag round-trips known tags and defaults to uzLatin', () {
      expect(AppLanguage.fromTag('ru'), AppLanguage.russian);
      expect(AppLanguage.fromTag('uz_Cyrl'), AppLanguage.uzCyrillic);
      expect(AppLanguage.fromTag('uz'), AppLanguage.uzLatin);
      expect(AppLanguage.fromTag(null), AppLanguage.uzLatin);
      expect(AppLanguage.fromTag('xx'), AppLanguage.uzLatin);
    });
  });
}
