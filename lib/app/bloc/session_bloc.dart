import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/token_service.dart';

part 'session_event.dart';
part 'session_state.dart';

/// Auth / sessiya holatining yagona manbasi (app-level BLoC).
///
/// Router shu blocning [stream]ini tinglaydi va har emissiyada redirect guardini
/// qayta hisoblaydi:
/// `splash → login (token yo‘q) → faceVerify (login bo‘ldi, yuz kerak) → home`.
///
/// PIN / rol / fon-timeout oqimlari olib tashlangan — bu loyihada yuz tasdig‘i
/// yagona ikkinchi bosqich. Tokenlar yuz tasdiqlangach (`SessionFaceVerified`)
/// saqlanadi; ungacha RAM’da turadi.
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc({
    required TokenService tokenService,
    required StorageService storage,
  })  : _tokenService = tokenService,
        _storage = storage,
        super(const SessionState.unknown()) {
    on<SessionStarted>(_onStarted);
    on<SessionLoginSucceeded>(_onLoginSucceeded);
    on<SessionFaceVerified>(_onFaceVerified);
    on<SessionExpired>(_onExpired);
    on<SessionLogoutRequested>(_onLogoutRequested);
  }

  final TokenService _tokenService;
  final StorageService _storage;

  // ── RAM’dagi (hali saqlanmagan) login natijasi ────────────────────────
  String? _pendingAccess;
  String? _pendingRefresh;
  String? _pendingFullName;
  String? _pendingFaceImage;

  /// Yuz so‘roviga Bearer sifatida biriktiriladigan, hali saqlanmagan token.
  String? get pendingAccessToken => _pendingAccess;

  /// Face ekrani kartasi uchun login’da kiritilgan ism.
  String? get pendingFullName => _pendingFullName;

  /// Login javobidagi profil rasmi — `null`/bo‘sh bo‘lsa yuzdan oldin rasm
  /// so‘rovi ko‘rsatiladi (face ekrani gate’i shu qiymatdan kelib chiqadi).
  String? get pendingFaceImage => _pendingFaceImage;

  bool get _hasToken {
    final token = _tokenService.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> _onStarted(
    SessionStarted event,
    Emitter<SessionState> emit,
  ) async {
    // Saqlangan token bor → to‘liq autentifikatsiya (yuz qayta so‘ralmaydi).
    emit(
      _hasToken
          ? const SessionState.authenticated()
          : const SessionState.unauthenticated(),
    );
  }

  Future<void> _onLoginSucceeded(
    SessionLoginSucceeded event,
    Emitter<SessionState> emit,
  ) async {
    _pendingAccess = event.accessToken;
    _pendingRefresh = event.refreshToken;
    _pendingFullName = event.fullName;
    _pendingFaceImage = event.faceImage;
    emit(const SessionState.faceVerificationRequired());
  }

  Future<void> _onFaceVerified(
    SessionFaceVerified event,
    Emitter<SessionState> emit,
  ) async {
    final access = _pendingAccess;
    final refresh = _pendingRefresh;
    if (access == null || access.isEmpty) {
      // Pending yo‘q — xavfsiz default: qayta login.
      emit(const SessionState.unauthenticated());
      return;
    }
    await _tokenService.saveToken(access);
    if (refresh != null && refresh.isNotEmpty) {
      await _tokenService.saveRefreshToken(refresh);
    }
    if (_pendingFullName != null) {
      await _storage.setString(StorageKeys.loginUsername, _pendingFullName!);
    }
    _clearPending();
    emit(const SessionState.authenticated());
  }

  Future<void> _onExpired(
    SessionExpired event,
    Emitter<SessionState> emit,
  ) async {
    _clearPending();
    await _clearAll();
    emit(const SessionState.unauthenticated());
  }

  Future<void> _onLogoutRequested(
    SessionLogoutRequested event,
    Emitter<SessionState> emit,
  ) async {
    _clearPending();
    await _clearAll();
    emit(const SessionState.unauthenticated());
  }

  void _clearPending() {
    _pendingAccess = null;
    _pendingRefresh = null;
    _pendingFullName = null;
    _pendingFaceImage = null;
  }

  Future<void> _clearAll() async {
    await _tokenService.clearAll();
    await _storage.remove(StorageKeys.cachedUser);
    await _storage.remove(StorageKeys.loginUsername);
  }
}
