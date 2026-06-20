import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/bloc/locale/locale_bloc.dart';
import 'app/bloc/session_bloc.dart';
import 'app/bloc/theme/theme_bloc.dart';
import 'config/routes/coordinator.dart';
import 'core/constants/storage_keys.dart';
import 'core/network/dio_client.dart';
import 'core/network/dio_factory.dart';
import 'core/network/interceptors/auth_interceptor.dart';
import 'core/network/interceptors/logging_interceptor.dart';
import 'core/network/interceptors/refresh_interceptor.dart';
import 'core/services/attendance_sync_manager.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/face_embedding_service.dart';
import 'core/services/image_picker_service.dart';
import 'core/services/location_service.dart';
import 'core/services/logger_service.dart';
import 'core/services/offline_secret_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/token_service.dart';
import 'features/attendance/data/data_sources/attendance_local_data_source.dart';
import 'features/attendance/data/data_sources/attendance_remote_data_source.dart';
import 'features/attendance/data/data_sources/geozone_remote_data_source.dart';
import 'features/attendance/data/repository/attendance_repository_impl.dart';
import 'features/attendance/data/repository/face_reference_repository_impl.dart';
import 'features/attendance/data/repository/geozone_repository_impl.dart';
import 'features/attendance/domain/repository/attendance_repository.dart';
import 'features/attendance/domain/repository/face_reference_repository.dart';
import 'features/attendance/domain/repository/geozone_repository.dart';
import 'features/attendance/domain/usecases/cache_geozone_usecase.dart';
import 'features/attendance/domain/usecases/ensure_reference_embedding_usecase.dart';
import 'features/attendance/domain/usecases/get_today_attendance_usecase.dart';
import 'features/attendance/domain/usecases/mark_attendance_usecase.dart';
import 'features/attendance/domain/usecases/sync_pending_attendance_usecase.dart';
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
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/onboarding/data/data_sources/onboarding_remote_data_source.dart';
import 'features/onboarding/data/repository/onboarding_repository_impl.dart';
import 'features/onboarding/domain/repository/onboarding_repository.dart';
import 'features/onboarding/domain/usecases/change_password_usecase.dart';
import 'features/onboarding/presentation/bloc/onboarding_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ── Lokal saqlash (Hive) — offline navbat + cache bokslari ──────────────
  await Hive.initFlutter();
  final pendingBox = await Hive.openBox<String>(AttendanceBoxes.pending);
  final cacheBox = await Hive.openBox<String>(AttendanceBoxes.cache);

  // ── Core services ─────────────────────────────────────────────────────
  final storage = await StorageService.persistent(allowList: StorageKeys.all);
  getIt
    ..registerSingleton<StorageService>(storage)
    ..registerLazySingleton<LoggerService>(() => LoggerService())
    ..registerLazySingleton<TokenService>(() => TokenService(getIt()))
    ..registerLazySingleton<ImagePickerService>(() => ImagePickerService())
    ..registerLazySingleton<LocationService>(() => const LocationService())
    ..registerLazySingleton<ConnectivityService>(() => ConnectivityService())
    ..registerLazySingleton<OfflineSecretService>(() => OfflineSecretService())
    ..registerLazySingleton<FaceEmbeddingService>(() => FaceEmbeddingService())
    ..registerSingleton<AttendanceLocalDataSource>(
      AttendanceLocalDataSource(pendingBox: pendingBox, cacheBox: cacheBox),
    );

  // App-level state — singletons so router + UI share one instance each.
  getIt
    ..registerLazySingleton<SessionBloc>(
      () => SessionBloc(
        tokenService: getIt(),
        storage: getIt(),
        offlineSecret: getIt(),
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
        embedding: getIt(),
        offlineSecret: getIt(),
        attendanceRepository: getIt(),
        geozoneRepository: getIt(),
        faceReferenceRepository: getIt(),
      ),
    );

  // ── Attendance feature (yuz-tekshiruv + GPS + POST + bugungi GET +
  //    offline navbat + geozone + reference embedding) ─────────────────────
  getIt
    ..registerLazySingleton<AttendanceRemoteDataSource>(
      () => AttendanceRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<GeozoneRemoteDataSource>(
      () => GeozoneRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<AttendanceRepository>(
      () => AttendanceRepositoryImpl(remote: getIt(), local: getIt()),
    )
    ..registerLazySingleton<GeozoneRepository>(
      () => GeozoneRepositoryImpl(remote: getIt(), local: getIt()),
    )
    ..registerLazySingleton<FaceReferenceRepository>(
      () => FaceReferenceRepositoryImpl(embedding: getIt(), local: getIt()),
    )
    ..registerLazySingleton<MarkAttendanceUseCase>(
      () => MarkAttendanceUseCase(getIt()),
    )
    ..registerLazySingleton<GetTodayAttendanceUseCase>(
      () => GetTodayAttendanceUseCase(getIt()),
    )
    ..registerLazySingleton<CacheGeozoneForBranchUseCase>(
      () => CacheGeozoneForBranchUseCase(getIt()),
    )
    ..registerLazySingleton<EnsureReferenceEmbeddingUseCase>(
      () => EnsureReferenceEmbeddingUseCase(getIt()),
    )
    ..registerLazySingleton<SyncPendingAttendanceUseCase>(
      () => SyncPendingAttendanceUseCase(getIt()),
    )
    ..registerLazySingleton<AttendanceSyncManager>(
      () => AttendanceSyncManager(
        connectivity: getIt(),
        sync: getIt(),
        session: getIt(),
        logger: getIt(),
      ),
    );

  // ── Home (asosiy ekran davomat holati — backend bugungi yozuvlardan) ────
  getIt.registerFactory<AttendanceBloc>(
    () => AttendanceBloc(getToday: getIt()),
  );

  // ── Profile feature ───────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(getIt()),
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
      ),
    );

  // ── Onboarding feature ────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<OnboardingRemoteDataSource>(
      () => OnboardingRemoteDataSourceImpl(getIt()),
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
        offlineSecret: getIt(),
      ),
    );

  // ── Router — built once from the session bloc. ──────────────────────────
  getIt.registerLazySingleton<AppRouter>(() => AppRouter(getIt<SessionBloc>()));
}
