import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/services/offline_secret_store.dart';
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
    required OfflineSecretStore offlineSecretStore,
  })  : _tokenService = tokenService,
        _storage = storage,
        _offlineSecretStore = offlineSecretStore,
        super(const SessionState.unknown()) {
    on<SessionStarted>(_onStarted);
    on<SessionLoginSucceeded>(_onLoginSucceeded);
    on<SessionFaceVerified>(_onFaceVerified);
    on<SessionExpired>(_onExpired);
    on<SessionLogoutRequested>(_onLogoutRequested);
  }

  final TokenService _tokenService;
  final StorageService _storage;
  final OfflineSecretStore _offlineSecretStore;

  /// Onboarding shu qurilmada kamida bir marta tugatilganmi (device-once).
  /// `_onStarted`da storage’dan o‘qiladi; yuz tasdiqlangach `true`ga o‘tadi va
  /// saqlanadi. Logout/expire’da TOZALANMAYDI — keyingi login’lar onboardingni
  /// emas, to‘g‘ridan-to‘g‘ri yuz tasdig‘ini ko‘radi.
  bool _onboardingCompleted = false;

  /// Guard shu qiymatdan kelib chiqib `faceVerificationRequired`da onboarding
  /// (birinchi marta) yoki yuz tasdig‘i (keyin) sahifasini tanlaydi.
  bool get requiresOnboarding => !_onboardingCompleted;

  // ── RAM’dagi (hali saqlanmagan) login natijasi ────────────────────────
  String? _pendingAccess;
  String? _pendingRefresh;
  String? _pendingFullName;
  String? _pendingLoginPassword;
  String? _pendingFaceImage;
  String? _pendingOfflineSecret;
  bool _pendingIsPasswordChanged = true;

  /// Yuz so‘roviga Bearer sifatida biriktiriladigan, hali saqlanmagan token.
  String? get pendingAccessToken => _pendingAccess;

  /// Face ekrani kartasi uchun login’da kiritilgan ism.
  String? get pendingFullName => _pendingFullName;

  /// Login’da kiritilgan parol — onboarding parol bosqichida «eski parol».
  String? get pendingLoginPassword => _pendingLoginPassword;

  /// Login javobidagi profil rasmi — `null`/bo‘sh bo‘lsa yuzdan oldin rasm
  /// so‘rovi ko‘rsatiladi (onboarding gate’i shu qiymatdan kelib chiqadi).
  String? get pendingFaceImage => _pendingFaceImage;

  /// Login javobidagi `is_password_changed` — onboarding parol bosqichi
  /// shu qiymatdan kelib chiqadi (`false` → parol o‘rnatish bosqichi).
  bool get pendingIsPasswordChanged => _pendingIsPasswordChanged;

  bool get _hasToken {
    final token = _tokenService.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Dispatched by [SplashPage] once its «Davomat» reveal animation finishes,
  /// so the splash is guaranteed visible for its full duration regardless of
  /// engine warm-up (the native splash covers warm-up; this resolves after).
  Future<void> _onStarted(SessionStarted event, Emitter<SessionState> emit) async {
    // Onboarding bir marta tugatilgan-tugatilmaganini o‘qib qo‘yamiz (device-once).
    final flag = _storage.getString(StorageKeys.onboardingCompleted);
    _onboardingCompleted = flag == '1' || flag == 'true';
    // Saqlangan token bor → to‘liq autentifikatsiya (yuz qayta so‘ralmaydi).
    emit(_hasToken ? const SessionState.authenticated() : const SessionState.unauthenticated());
  }

  Future<void> _onLoginSucceeded(SessionLoginSucceeded event, Emitter<SessionState> emit) async {
    _pendingAccess = event.accessToken;
    _pendingRefresh = event.refreshToken;
    _pendingFullName = event.fullName;
    _pendingLoginPassword = event.loginPassword;
    _pendingFaceImage = event.faceImage;
    _pendingOfflineSecret = event.offlineSecret;
    _pendingIsPasswordChanged = event.isPasswordChanged;

    // Login’da kiritilgan ism aynan «Ali Aliyev» bo‘lsa → yuz tasdig‘i ham,
    // onboarding ham o‘tkazib yuboriladi, to‘g‘ridan-to‘g‘ri uy ekraniga
    // (tokenlar darhol saqlanadi). Boshqa shart yo‘q.
    if (event.fullName.trim() == 'Ali Aliyev') {
      await _persistSession(emit);
      return;
    }

    emit(const SessionState.faceVerificationRequired());
  }

  Future<void> _onFaceVerified(SessionFaceVerified event, Emitter<SessionState> emit) async {
    if (_pendingAccess == null || _pendingAccess!.isEmpty) {
      // Pending yo‘q — xavfsiz default: qayta login.
      emit(const SessionState.unauthenticated());
      return;
    }
    await _persistSession(emit);
  }

  /// RAM’dagi login natijasini diskka saqlaydi va `authenticated`ga o‘tadi.
  /// Yuz tasdig‘idan keyin ham, sozlash kerak bo‘lmagan to‘g‘ridan-to‘g‘ri
  /// login’da ham ishlatiladi.
  Future<void> _persistSession(Emitter<SessionState> emit) async {
    final access = _pendingAccess;
    final refresh = _pendingRefresh;
    if (access == null || access.isEmpty) {
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
    // offline_secret’ni xavfsiz xotiraga yozamiz (offline davomat HMAC kaliti).
    if (_pendingOfflineSecret != null && _pendingOfflineSecret!.isNotEmpty) {
      await _offlineSecretStore.write(_pendingOfflineSecret!);
    }
    // Onboarding/yuz tasdig‘i kamida bir marta tugadi — device-once flag.
    await _storage.setString(StorageKeys.onboardingCompleted, '1');
    _onboardingCompleted = true;
    _clearPending();
    emit(const SessionState.authenticated());
  }

  Future<void> _onExpired(SessionExpired event, Emitter<SessionState> emit) async {
    _clearPending();
    await _clearAll();
    emit(const SessionState.unauthenticated());
  }

  Future<void> _onLogoutRequested(SessionLogoutRequested event, Emitter<SessionState> emit) async {
    _clearPending();
    await _clearAll();
    emit(const SessionState.unauthenticated());
  }

  void _clearPending() {
    _pendingAccess = null;
    _pendingRefresh = null;
    _pendingFullName = null;
    _pendingLoginPassword = null;
    _pendingFaceImage = null;
    _pendingOfflineSecret = null;
    _pendingIsPasswordChanged = true;
  }

  Future<void> _clearAll() async {
    await _tokenService.clearAll();
    await _offlineSecretStore.clear();
    await _storage.remove(StorageKeys.cachedUser);
    await _storage.remove(StorageKeys.loginUsername);
  }
}
