import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../app/bloc/session_bloc.dart';
import '../../features/notifications/domain/usecases/register_device_usecase.dart';
import '../constants/storage_keys.dart';
import 'storage_service.dart';
import 'token_service.dart';

/// FCM background handler — top-level (alohida izolatda chaqiriladi).
///
/// Ilova fonda/yopiq bo‘lganda kelgan xabarlarni OS o‘zi tray’da ko‘rsatadi;
/// bu yerda faqat Firebase tayyorligini ta’minlaymiz. `bootstrap` allaqachon
/// `Firebase.initializeApp` chaqiradi, lekin izolat alohida bo‘lgani uchun
/// bu handler kerak bo‘lsa qayta init qiladi.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Hech qanday UI yo‘q — data-only xabarlar uchun ham xavfsiz no-op.
}

/// Push bildirishnomalarni boshqaruvchi xizmat (FCM + lokal bildirishnoma).
///
/// Vazifalari:
/// - Ruxsat so‘rash + FCM tokenini olish va backendda ro‘yxatdan o‘tkazish
///   (foydalanuvchi autentifikatsiyadan o‘tganda va token yangilanganda).
/// - Old planda kelgan xabarni lokal bildirishnoma sifatida ko‘rsatish.
/// - Bildirishnoma bosilganda «Bildirishnomalar» ekraniga o‘tkazish.
/// - Yangi xabar kelganda [messages] orqali UI’ni xabardor qilish (badge).
class PushNotificationService {
  PushNotificationService({
    required RegisterDeviceUseCase registerDevice,
    required StorageService storage,
    required SessionBloc session,
    required TokenService tokenService,
    required void Function() onOpenNotifications,
  })  : _registerDevice = registerDevice,
        _storage = storage,
        _session = session,
        _tokenService = tokenService,
        _onOpenNotifications = onOpenNotifications;

  final RegisterDeviceUseCase _registerDevice;
  final StorageService _storage;
  final SessionBloc _session;
  final TokenService _tokenService;
  final void Function() _onOpenNotifications;

  final _messaging = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();

  /// Old planda yangi xabar kelganda emit qiladi — UI badge/ro‘yxatni yangilaydi.
  final _messages = StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get messages => _messages.stream;

  StreamSubscription<SessionState>? _sessionSub;
  StreamSubscription<String>? _tokenSub;
  bool _initialized = false;

  /// Oxirgi muvaffaqiyatli ro‘yxatdan o‘tgan FCM token — takroriy POSTlarni
  /// (start’da `authenticated` bir necha bor emit bo‘lishi) to‘sadi, aks holda
  /// backend bir qurilma uchun bir nechta token yozib, push dublikat bo‘ladi.
  String? _lastRegisteredToken;

  static const _channel = AndroidNotificationChannel(
    'hgt_default_channel',
    'Bildirishnomalar',
    description: 'Davomat va tizim bildirishnomalari',
    importance: Importance.high,
  );

  /// Bir marta chaqiriladi (bootstrap). Listenerlarni o‘rnatadi, ruxsat so‘raydi,
  /// allaqachon autentifikatsiyadan o‘tilgan bo‘lsa tokenni darhol sinxronlaydi.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _initLocalNotifications();

    // iOS old planda ham banner ko‘rsatsin (lokal bildirishnomasiz).
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Old plandagi xabar → lokal bildirishnoma + badge signali.
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Bildirishnoma bosib ilova ochilganda → ro‘yxat ekraniga.
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpen);

    // Sovuq start (ilova yopiq edi, bildirishnoma orqali ochildi).
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _handleOpen(initial);
    }

    // Token yangilanganda qayta ro‘yxatdan o‘tkazamiz (auth bo‘lsa).
    _tokenSub = _messaging.onTokenRefresh.listen((token) {
      if (_session.state.isAuthenticated) _register(token);
    });

    // Auth holatiga qarab: kirilganda token sinxron, chiqilganda o‘chiramiz.
    _sessionSub = _session.stream.listen((state) {
      if (state.isAuthenticated) {
        syncToken();
      } else if (state.isUnauthenticated) {
        _deleteToken();
      }
    });
    if (_session.state.isAuthenticated) {
      await syncToken();
    }
  }

  /// FCM tokenini olib backendda ro‘yxatdan o‘tkazadi (auth talab qilinadi).
  Future<void> syncToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) await _register(token);
    } catch (e) {
      debugPrint('PushNotificationService.syncToken xatosi: $e');
    }
  }

  Future<void> _register(String token) async {
    final userId = _tokenService.getUserId();
    if (userId == null || userId.isEmpty) {
      debugPrint('PushNotificationService._register: user_id yo‘q, o‘tkazildi');
      return;
    }
    // Ayni token allaqachon ro‘yxatdan o‘tgan bo‘lsa — qayta yubormaymiz
    // (dublikat token/dublikat push oldini olish).
    if (token == _lastRegisteredToken) return;
    try {
      await _registerDevice(RegisterDeviceParams(
        userId: userId,
        fcmToken: token,
        deviceType: _deviceType,
        deviceId: _deviceId(),
      ));
      _lastRegisteredToken = token;
    } catch (e) {
      // Ro‘yxat xatosi — push kritik bo‘lmagani uchun jim qoldiramiz.
      debugPrint('PushNotificationService._register xatosi: $e');
    }
  }

  Future<void> _deleteToken() async {
    _lastRegisteredToken = null; // chiqishda — keyingi login qayta ro‘yxatdan o‘tsin.
    try {
      await _messaging.deleteToken();
    } catch (_) {/* e’tiborsiz */}
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _local.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) => _onOpenNotifications(),
    );
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  /// Asosiy (home) sahifaga o‘tilganda chaqiriladi — bildirishnoma ruxsati
  /// hali so‘ralmagan/aniqlanmagan bo‘lsagina tizim so‘rovini ko‘rsatadi.
  /// App start’da (login/face-verify’dan oldin) so‘ramaymiz, faqat home’ga
  /// kirgach va hali ruxsat berilmagan bo‘lsa.
  Future<void> requestPermissionIfNeeded() async {
    final settings = await _messaging.getNotificationSettings();
    final alreadyGranted = settings.authorizationStatus ==
            AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    if (alreadyGranted) return;
    await _requestPermission();
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission();
    // Android 13+ — POST_NOTIFICATIONS runtime ruxsati.
    if (Platform.isAndroid) {
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    _messages.add(message);
    final notification = message.notification;
    if (notification == null) return; // data-only — tray ko‘rsatmaydi.

    // Bir xil xabar bir nechta token’ga kelsa (backend dublikati) — bir xil
    // `id` bilan ko‘rsatamiz, shunda OS stack qilmasdan almashtiradi (1 ta).
    // Kalit: backend `data['id']` bo‘lsa o‘sha, aks holda sarlavha+matn.
    final dedupKey = message.data['id']?.toString().isNotEmpty == true
        ? message.data['id'].toString()
        : '${notification.title}|${notification.body}';

    _local.show(
      id: dedupKey.hashCode & 0x7fffffff,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data['id']?.toString(),
    );
  }

  void _handleOpen(RemoteMessage message) {
    _onOpenNotifications();
  }

  String get _deviceType => Platform.isIOS ? 'ios' : 'android';

  /// Barqaror qurilma identifikatori — birinchi marta yaratilib saqlanadi.
  String _deviceId() {
    final existing = _storage.getString(StorageKeys.deviceId);
    if (existing != null && existing.isNotEmpty) return existing;
    final rnd = Random();
    final id =
        '${DateTime.now().microsecondsSinceEpoch.toRadixString(16)}-${rnd.nextInt(0x7fffffff).toRadixString(16)}';
    _storage.setString(StorageKeys.deviceId, id);
    return id;
  }

  Future<void> dispose() async {
    await _sessionSub?.cancel();
    await _tokenSub?.cancel();
    await _messages.close();
  }
}
