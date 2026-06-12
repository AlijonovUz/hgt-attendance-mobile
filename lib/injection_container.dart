import 'package:get_it/get_it.dart';

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
import 'core/services/image_picker_service.dart';
import 'core/services/logger_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/token_service.dart';
import 'features/auth/data/data_sources/auth_remote_data_source.dart';
import 'features/auth/data/repository/auth_repository_impl.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/verify_face_usecase.dart';
import 'features/auth/presentation/bloc/login_bloc.dart';
import 'features/auth/presentation/face/bloc/face_verify_bloc.dart';
import 'features/profile/data/data_sources/profile_remote_data_source.dart';
import 'features/profile/data/repository/profile_repository_impl.dart';
import 'features/profile/domain/repository/profile_repository.dart';
import 'features/profile/domain/usecases/get_profile_usecase.dart';
import 'features/profile/domain/usecases/update_face_image_usecase.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ── Core services ─────────────────────────────────────────────────────
  final storage = await StorageService.persistent(allowList: StorageKeys.all);
  getIt
    ..registerSingleton<StorageService>(storage)
    ..registerLazySingleton<LoggerService>(() => LoggerService())
    ..registerLazySingleton<TokenService>(() => TokenService(getIt()))
    ..registerLazySingleton<ImagePickerService>(() => ImagePickerService());

  // App-level state — singletons so router + UI share one instance each.
  getIt
    ..registerLazySingleton<SessionBloc>(
      () => SessionBloc(tokenService: getIt(), storage: getIt()),
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
    ..registerFactory<FaceVerifyBloc>(
      () => FaceVerifyBloc(verifyFaceUseCase: getIt()),
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

  // ── Router — built once from the session bloc. ──────────────────────────
  getIt.registerLazySingleton<AppRouter>(() => AppRouter(getIt<SessionBloc>()));
}
