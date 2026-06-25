import 'package:get_it/get_it.dart';

import 'app/bloc/locale/locale_bloc.dart';
import 'app/bloc/session_bloc.dart';
import 'app/bloc/theme/theme_bloc.dart';
import 'config/routes/coordinator.dart';
import 'config/routes/entity/routes.dart';
import 'core/constants/storage_keys.dart';
import 'core/network/dio_client.dart';
import 'core/network/dio_factory.dart';
import 'core/network/interceptors/auth_interceptor.dart';
import 'core/network/interceptors/logging_interceptor.dart';
import 'core/network/interceptors/refresh_interceptor.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/face_embedder_service.dart';
import 'core/services/face_image_cache_service.dart';
import 'core/services/face_match_service.dart';
import 'core/services/geofence_service.dart';
import 'core/services/geozone_cache_store.dart';
import 'core/services/hmac_signer.dart';
import 'core/services/image_picker_service.dart';
import 'core/services/location_service.dart';
import 'core/services/offline_attendance_store.dart';
import 'core/services/offline_secret_store.dart';
import 'core/services/offline_sync_service.dart';
import 'core/services/logger_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/token_service.dart';
import 'core/services/vpn_detector_service.dart';
import 'features/attendance/data/data_sources/attendance_remote_data_source.dart';
import 'features/attendance/data/data_sources/geozone_remote_data_source.dart';
import 'features/attendance/data/repository/attendance_repository_impl.dart';
import 'features/attendance/data/repository/geozone_repository_impl.dart';
import 'features/attendance/domain/repository/attendance_repository.dart';
import 'features/attendance/domain/repository/geozone_repository.dart';
import 'features/attendance/domain/usecases/get_attendance_history_usecase.dart';
import 'features/attendance/domain/usecases/get_personal_stats_usecase.dart';
import 'features/attendance/domain/usecases/get_today_attendance_usecase.dart';
import 'features/attendance/domain/usecases/mark_attendance_usecase.dart';
import 'features/attendance/domain/usecases/sync_user_geozone_usecase.dart';
import 'features/attendance/presentation/bloc/history/attendance_history_bloc.dart';
import 'features/auth/data/data_sources/auth_remote_data_source.dart';
import 'features/auth/data/repository/auth_repository_impl.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/verify_face_usecase.dart';
import 'features/auth/presentation/bloc/login_bloc.dart';
import 'features/auth/presentation/face/bloc/face_verify_bloc.dart';
import 'features/home/presentation/bloc/attendance_bloc.dart';
import 'features/profile/data/data_sources/profile_remote_data_source.dart';
import 'features/profile/data/repository/profile_repository_impl.dart';
import 'features/profile/domain/repository/profile_repository.dart';
import 'features/profile/domain/usecases/get_profile_usecase.dart';
import 'features/profile/domain/usecases/update_face_image_usecase.dart';
import 'features/profile/presentation/bloc/change_password_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/notifications/data/data_sources/notification_remote_data_source.dart';
import 'features/notifications/data/data_sources/notification_socket_service.dart';
import 'features/notifications/data/repository/notification_repository_impl.dart';
import 'features/notifications/domain/repository/notification_repository.dart';
import 'features/notifications/domain/usecases/get_notification_count_usecase.dart';
import 'features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'features/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'features/notifications/domain/usecases/register_device_usecase.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';
import 'features/onboarding/data/data_sources/onboarding_remote_data_source.dart';
import 'features/onboarding/data/repository/onboarding_repository_impl.dart';
import 'features/onboarding/domain/repository/onboarding_repository.dart';
import 'features/onboarding/domain/usecases/change_password_usecase.dart';
import 'features/onboarding/presentation/bloc/onboarding_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ── Core services ─────────────────────────────────────────────────────
  final storage = await StorageService.persistent(allowList: StorageKeys.all);
  getIt
    ..registerSingleton<StorageService>(storage)
    ..registerLazySingleton<LoggerService>(() => LoggerService())
    ..registerLazySingleton<TokenService>(() => TokenService(getIt()))
    ..registerLazySingleton<ImagePickerService>(() => ImagePickerService())
    ..registerLazySingleton<LocationService>(() => const LocationService())
    ..registerLazySingleton<VpnDetectorService>(() => VpnDetectorService())
    ..registerLazySingleton<ConnectivityService>(() => ConnectivityService())
    // Yuz rasmini lokal xotiraga keshlash (offline yuz tasdig‘i + avatar).
    ..registerLazySingleton<FaceImageCacheService>(
      () => FaceImageCacheService(DioFactory.create()),
    )
    // offline_secret xavfsiz xotirasi (HMAC kaliti).
    ..registerLazySingleton<OfflineSecretStore>(() => OfflineSecretStore())
    // Geofence (haversine) + keshlangan geozona (offline ish joyi tekshiruvi).
    ..registerLazySingleton<GeofenceService>(() => const GeofenceService())
    ..registerLazySingleton<GeozoneCacheStore>(() => GeozoneCacheStore(getIt()))
    // Offline yuz moslik (MobileFaceNet embedding + ML Kit bbox).
    ..registerLazySingleton<FaceEmbedderService>(() => FaceEmbedderService())
    ..registerLazySingleton<FaceMatchService>(() => FaceMatchService(getIt()))
    // Offline navbat (JSON-fayl) + HMAC imzo.
    ..registerLazySingleton<HmacSigner>(() => const HmacSigner())
    ..registerLazySingleton<OfflineAttendanceStore>(
      () => OfflineAttendanceStore(),
    );

  // Offline davomat sinxron dvigateli — connectivity + session’ni tinglaydi.
  getIt.registerLazySingleton<OfflineSyncService>(
    () => OfflineSyncService(
      store: getIt(),
      repository: getIt(),
      connectivity: getIt(),
      session: getIt(),
      logger: getIt(),
    ),
  );

  // App-level state — singletons so router + UI share one instance each.
  getIt
    ..registerLazySingleton<SessionBloc>(
      () => SessionBloc(
        tokenService: getIt(),
        storage: getIt(),
        offlineSecretStore: getIt(),
      ),
    )
    ..registerLazySingleton<ThemeBloc>(() => ThemeBloc(storage: getIt()))
    ..registerLazySingleton<LocaleBloc>(() => LocaleBloc(storage: getIt()));

  // ── Network ───────────────────────────────────────────────────────────
  getIt.registerLazySingleton<DioClient>(() {
    final dio = DioFactory.create();
    // Refresh uchun alohida (interceptorsiz) Dio — sikldan saqlaydi.
    final refreshDio = DioFactory.create();
    dio.interceptors.addAll([
      AuthInterceptor(getIt<TokenService>()),
      RefreshInterceptor(
        tokenService: getIt<TokenService>(),
        refreshDio: refreshDio,
        session: () => getIt<SessionBloc>(),
      ),
      LoggingInterceptor(getIt<LoggerService>()),
    ]);
    return DioClient(dio);
  });

  // ── Auth feature ──────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remote: getIt(), tokenService: getIt()),
    )
    ..registerLazySingleton<LoginUseCase>(() => LoginUseCase(getIt()))
    ..registerLazySingleton<VerifyFaceUseCase>(() => VerifyFaceUseCase(getIt()))
    ..registerFactory<LoginBloc>(() => LoginBloc(loginUseCase: getIt()))
    // Universal yuz-tekshiruv (login gate + davomat) — verify-face, mark-attendance
    // va GPS injekt qilinadi; rejim `FaceStarted(mode)` orqali tanlanadi.
    ..registerFactory<FaceVerifyBloc>(
      () => FaceVerifyBloc(
        verifyFaceUseCase: getIt(),
        markAttendance: getIt(),
        location: getIt(),
        connectivity: getIt(),
        geofence: getIt(),
        geozoneCache: getIt(),
        faceMatch: getIt(),
        offlineSecret: getIt(),
        hmacSigner: getIt(),
        offlineStore: getIt(),
        faceImageCache: getIt(),
        tokenService: getIt(),
      ),
    );

  // ── Attendance feature (yuz-tekshiruv + GPS + POST + bugungi GET) ───────
  getIt
    ..registerLazySingleton<AttendanceRemoteDataSource>(
      () => AttendanceRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<AttendanceRepository>(
      () => AttendanceRepositoryImpl(remote: getIt()),
    )
    ..registerLazySingleton<MarkAttendanceUseCase>(
      () => MarkAttendanceUseCase(getIt()),
    )
    ..registerLazySingleton<GetTodayAttendanceUseCase>(
      () => GetTodayAttendanceUseCase(getIt()),
    )
    ..registerLazySingleton<GetAttendanceHistoryUseCase>(
      () => GetAttendanceHistoryUseCase(getIt()),
    )
    ..registerLazySingleton<GetPersonalStatsUseCase>(
      () => GetPersonalStatsUseCase(getIt()),
    )
    ..registerFactory<AttendanceHistoryBloc>(
      () => AttendanceHistoryBloc(getHistory: getIt(), getStats: getIt()),
    )
    // Geozona (filial geofence) — online olib lokalga keshlanadi.
    ..registerLazySingleton<GeozoneRemoteDataSource>(
      () => GeozoneRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<GeozoneRepository>(
      () => GeozoneRepositoryImpl(remote: getIt()),
    )
    ..registerLazySingleton<SyncUserGeozoneUseCase>(
      () => SyncUserGeozoneUseCase(getIt(), getIt()),
    );

  // ── Home (asosiy ekran davomat holati — backend bugungi yozuvlardan) ────
  getIt.registerFactory<AttendanceBloc>(
    () => AttendanceBloc(
      getToday: getIt(),
      offlineStore: getIt(),
      syncService: getIt(),
    ),
  );

  // ── Profile feature ───────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(getIt(), getIt()),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(remote: getIt()),
    )
    ..registerLazySingleton<GetProfileUseCase>(() => GetProfileUseCase(getIt()))
    ..registerLazySingleton<UpdateFaceImageUseCase>(
      () => UpdateFaceImageUseCase(getIt()),
    )
    ..registerFactory<ProfileBloc>(
      () => ProfileBloc(
        getProfile: getIt(),
        updateFaceImage: getIt(),
        imagePicker: getIt(),
        faceImageCache: getIt(),
        syncGeozone: getIt(),
      ),
    )
    ..registerFactory<ChangePasswordBloc>(
      () => ChangePasswordBloc(changePassword: getIt()),
    );

  // ── Notifications feature ─────────────────────────────────────────────
  getIt
    ..registerLazySingleton<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(remote: getIt()),
    )
    ..registerLazySingleton<GetNotificationsUseCase>(
      () => GetNotificationsUseCase(getIt()),
    )
    ..registerLazySingleton<MarkNotificationReadUseCase>(
      () => MarkNotificationReadUseCase(getIt()),
    )
    ..registerLazySingleton<MarkAllNotificationsReadUseCase>(
      () => MarkAllNotificationsReadUseCase(getIt()),
    )
    ..registerLazySingleton<GetNotificationCountUseCase>(
      () => GetNotificationCountUseCase(getIt()),
    )
    ..registerLazySingleton<RegisterDeviceUseCase>(
      () => RegisterDeviceUseCase(getIt()),
    )
    // Real-time WebSocket — ticket olib ulanadi, jonli xabarlarni oqimga uzatadi.
    ..registerLazySingleton<NotificationSocketService>(
      () => NotificationSocketService(client: getIt(), session: getIt()),
    )
    ..registerFactory<NotificationBloc>(
      () => NotificationBloc(
        getNotifications: getIt(),
        markRead: getIt(),
        markAllRead: getIt(),
        getCount: getIt(),
        socket: getIt(),
      ),
    )
    // Push (FCM) — auth holatini tinglaydi, token sinxronlaydi, bosilganda
    // «Bildirishnomalar» ekraniga o‘tadi.
    ..registerLazySingleton<PushNotificationService>(
      () => PushNotificationService(
        registerDevice: getIt(),
        storage: getIt(),
        session: getIt(),
        tokenService: getIt(),
        onOpenNotifications: () =>
            getIt<AppRouter>().router.pushNamed(Routes.notifications.name),
      ),
    );

  // ── Onboarding feature ────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<OnboardingRemoteDataSource>(
      () => OnboardingRemoteDataSourceImpl(getIt(), getIt()),
    )
    ..registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepositoryImpl(remote: getIt()),
    )
    ..registerLazySingleton<ChangePasswordUseCase>(
      () => ChangePasswordUseCase(getIt()),
    )
    ..registerFactory<OnboardingBloc>(
      () => OnboardingBloc(
        changePassword: getIt(),
        getProfile: getIt(),
        updateFaceImage: getIt(),
        imagePicker: getIt(),
      ),
    );

  // ── Router — built once from the session bloc. ──────────────────────────
  getIt.registerLazySingleton<AppRouter>(() => AppRouter(getIt<SessionBloc>()));
}
