# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

`hgt_attendance_mobile` is a Flutter app on a Feature-First + Clean Architecture base, mirroring the `dc_management_app` ("Raqamli Boshqaruv") architecture 1:1. These rules are **mandatory** for every code-generation task in this repo.

## Commands

```bash
flutter pub get                         # install deps
flutter analyze lib                     # lint (must be clean before done)
flutter test                            # all tests
flutter test test/widget_test.dart      # single file
flutter test --plain-name "routes to login when no session exists"  # single test by name
flutter run                             # run on attached device/emulator
flutter build apk --release             # release APK (signed via android/key.properties)
dart run build_runner build --delete-conflicting-outputs   # codegen (flutter_gen assets)
flutter gen-l10n                        # regenerate localizations after editing any .arb
cd android && ./gradlew --stop          # kill stale Gradle daemon after editing gradle.properties
```

After any change: `flutter analyze lib` must report **0 issues** (one pre-existing info in `core/usecases/usecase.dart` aside).

> **Release build gotchas (Android):** (1) R8/minify needs `android/app/proguard-rules.pro` `-dontwarn org.tensorflow.lite.gpu.**` — `tflite_flutter` references the optional GPU delegate (`GpuDelegateFactory$Options`), which isn't on the classpath (CPU-only), and R8 fails the build as "missing class" without it. (2) `lint { checkReleaseBuilds = false }` in `android/app/build.gradle.kts` — `lintVitalAnalyzeRelease` OOM'd on `MaxMetaspaceSize`; run lint separately. (3) `android/gradle.properties` keeps a deliberately small footprint (this machine hits Windows error 1455 "paging file too small") — 1.5G heap, 1G metaspace, SerialGC. Bumping these risks OOM the other way; `useFullClasspathForDexingTransform=true` is required for `camera_android_camerax` nestmate dexing.

## Architecture

### Feature-First + Clean Architecture
Every feature lives under `lib/features/<feature>/` split into three layers — never collapse them:

- **data/** — `service` (API + local data sources), `repository_impl`, `model` (JSON serialization). Models map to/from entities; never leak `Model` types above the data layer.
- **domain/** — `repository` (abstract interface), `usecase` (one action each), `entity` (pure Dart, no Flutter/JSON imports). The domain layer depends on nothing outward.
- **presentation/** — `bloc` (state), `pages` + `widgets` (UI). UI talks to domain only through blocs.

Dependency direction is strictly inward: presentation → domain ← data. Apply SOLID / DRY / KISS. Shared cross-feature code goes in `lib/core/`; app-wide config (routes, theme) in `lib/config/`.

### Dependency injection
`get_it` (`lib/injection_container.dart`). Register every service/repository/bloc in `configureDependencies()`. `bootstrap()` (`lib/app/bootstrap.dart`) calls it before `runApp`. Resolve via `getIt<T>()`. Singletons for stateful shared instances (router, session); lazy for the rest.

### Navigation — centralized GoRouter
**All** routing lives in `lib/config/routes/coordinator.dart` (`AppRouter`). Rules:
- Route descriptors are declared **only** in `lib/config/routes/entity/routes.dart` (`Routes`, implementing `Coordinate`). Navigate by **name**, never raw path strings: `context.goNamed(Routes.home.name)`.
- A single `redirect` guard makes **all** routing decisions from `SessionBloc` state. `GoRouterRefreshStream` re-runs the guard on every bloc emission — so login / face-verify / logout transitions reroute automatically. **Never** branch on auth state inside a page or scatter imperative `context.go()` for guard concerns.
- Flow: `splash` (status `unknown`) → `login` (no token) → `faceVerify` / `onboarding` (`faceVerificationRequired`: logged in, second-step pending — the guard picks `onboarding` when `SessionBloc.requiresOnboarding`, else `faceVerify`) → `home` (verified). **No PIN, no role-select** — abandoned. `checkCode` (attendance) route still exists but is **not** in the guard chain.
- Add a screen: declare in `routes.dart` → add `GoRoute` in `coordinator.dart` → it is auto-protected by the guard (anything not splash/login/faceVerify requires full auth).

### State management — BLoC only
Use the **BLoC** pattern (events → states) for all feature state. **Cubits are not permitted** anywhere. Provide blocs via `BlocProvider` / `getIt`; UI reads with `context.read`/`BlocBuilder`/`BlocListener`.
> App-wide session/auth state lives in the app-level `SessionBloc` (`lib/app/bloc/session_bloc.dart`) — it drives the router guard. Statuses: `unknown` / `unauthenticated` / `faceVerificationRequired` / `authenticated`. App-level `ThemeBloc` (`bloc/theme/`) and `LocaleBloc` (`bloc/locale/`) drive `MaterialApp.themeMode` + `locale`. No cubits remain.

### Networking
`Dio` built in `injection_container` (`DioFactory.create()` from `core/network/`), wrapped by `DioClient` (exposes `get` / `post` / `patch`). Base URL `https://hkk-backend.raqamlinazorat.uz/api`; endpoints under `/v1/users/auth/` live in `core/constants/api_constants.dart`. Interceptors, in order: `AuthInterceptor` (attaches `Bearer` from `TokenService`) → `RefreshInterceptor` → `LoggingInterceptor`. The `RefreshInterceptor` is a `QueuedInterceptor`: on a 401 from a **non-auth** path it refreshes the access token via a separate interceptor-free `Dio` and replays the request; on refresh failure it fires `SessionExpired`. It **skips** `login`, `refresh`, `verify-face`, **and any request flagged `options.extra['skipRefresh'] == true`** (used by the profile photo PATCH during the face-verify gate, which authenticates with the not-yet-persisted RAM token — a refresh loop would be meaningless). Data sources tolerate both raw SimpleJWT (`{ access, refresh }`) and an enveloped `{ data, error, success }` response, mapping HTTP/business errors → typed `Exception`s (`core/error/`); repos map those to `Failure`s, blocs map `Failure`s to **error enums**, widgets localize. Typed errors carry structured fields parsed from `error.details` (e.g. `ThrottleFailure.retryAfterSeconds`, `UnauthorizedFailure.attemptsLeft`) — never surface the backend `errorMsg` to the user.

### Auth + face-verify flow
- Login API field is **`full_name`** (+ `password`); the field's **label is "Kirish", placeholder "Ism sharif"**. `LoginBloc` returns `AuthTokens` and emits them — it does **not** persist.
- **Throttling is backend-driven, text is client-side.** Data-source `_exceptionFromBody` reads `error.errorId` (401/429) + `error.details.{attempts_left, retry_after_seconds}` into typed exceptions → `UnauthorizedFailure(attemptsLeft)` / `ThrottleFailure(retryAfterSeconds, attemptsLeft)`. 401 → `LoginErrorKind.invalid` (red borders + localized "Yana N marta urinish mumkin", N = `attempts_left`); 429 → `LoginErrorKind.blocked` (`Timer.periodic` MM:SS countdown from `retry_after_seconds`). Countdown end → attempts reset to `LoginState.maxAttempts` (5). All visible strings come from l10n, never the backend `errorMsg`.
- **Tokens + face_image held in RAM** (`SessionBloc._pendingAccess/_pendingRefresh/_pendingFullName/_pendingFaceImage`) after `SessionLoginSucceeded`, status → `faceVerificationRequired`. The login response's `data.user.face_image` flows through `AuthTokens.faceImage` → `SessionLoginSucceeded.faceImage` → `_pendingFaceImage`. Persisted **only** on `SessionFaceVerified`. So killing the app mid-face → relaunch → back to login.
- **Face-verify entry gate** (`features/auth/presentation/face/`): if `pendingFaceImage` is empty, a **mandatory** (`dismissible: false`) photo modal (`showProfilePhotoPrompt`) shows first → user picks a device image → `PATCH /v1/users/auth/profile/` multipart `face_image` (manual RAM-token `Bearer` + `extra['skipRefresh']`) → **only then** the camera scan starts. If `face_image` already exists → straight to scan.
- Face scan: `FaceVerifyBloc` runs `camera` preview + `google_mlkit_face_detection`; a stable face auto-captures a selfie (`takePicture`) and POSTs it as **FormData `image` file** to `/v1/users/auth/verify-face/` with the RAM access token as manual `Bearer`. Circle border color = state (blue scan / green success / red fail). 2xx → `SessionFaceVerified`.
- On relaunch with a saved token (`SessionStarted`) → straight to `authenticated`/home (no re-login, no re-face).

### Profile feature
`features/profile/` (clean arch): `GET`/`PATCH /v1/users/auth/profile/`; the profile image field is **`face_image`** (URI, nullable). `ProfileBloc` loads the profile and uploads a device image via `ImagePickerService` (`core/services/`, wraps `image_picker`). `UpdateFaceImageUseCase` takes an **optional `accessToken`** — pass the RAM token at the face-verify gate (manual Bearer + `skipRefresh`), omit it at home (saved token via `AuthInterceptor`). Shared UI: `ProfileAvatarCard`, `showProfilePhotoPrompt` (dashed-circle picker with a `dismissible` flag). `HomePage` hosts its own `ProfileBloc` for the avatar; the home photo prompt is a fallback (the gate normally runs at face-verify).

### Notifications feature
`features/notifications/` (clean arch) — endpoints under `/v1/notifications/` (`api_constants.dart`): `GET /` (paginated `{count,next,results}`, `page` + `is_read` query), `PATCH /{id}/read/`, `POST /read-all/`, `GET /count/`, `POST /devices/register/`. Titles/messages arrive **trilingual** (`title_uz_latn|uz_cyrl|ru`, `message_*`); `AppNotification.title()/message()` pick by `languageCode`/`scriptCode` with graceful fallback — never localize these in l10n. `NotificationBloc` handles list load, infinite-scroll paging, optimistic mark-read/mark-all (reverts on `Failure`), and the unread `count` (drives the home-bell badge in `HomeHeader`). The page is pushed from the home bell (route `Routes.notifications`, guarded like any authed route); `HomePage` also hosts a `NotificationBloc` for the badge and re-requests count on return.

### Push notifications (FCM)
`core/services/push_notification_service.dart` (singleton, registered in DI) wraps `firebase_messaging` + `flutter_local_notifications`. `bootstrap()` calls `Firebase.initializeApp` (with `firebase_options.dart`), registers the top-level `firebaseMessagingBackgroundHandler` (must be `@pragma('vm:entry-point')`), then `init()`s the service. The service **listens to `SessionBloc`**: on `authenticated` it gets the FCM token and `POST /devices/register/`; on `unauthenticated` it `deleteToken`s; it also re-registers on `onTokenRefresh`. **Register body requires `user`** (backend rejects without it) = the JWT `user_id` claim, read via `TokenService.getUserId()` (base64url-decodes the access token payload) — equals the profile `id`. Foreground messages show a local notification (Android channel `hgt_default_channel`) and ping `messages` stream so the badge refreshes; taps (foreground/background/`getInitialMessage`) navigate to the notifications route via the router. `device_id` is a stable random id persisted in `StorageKeys.deviceId`.

> **Native config gotcha (caused a build break):** the Android `applicationId`/`namespace` (`android/app/build.gradle.kts`), the `package_name` in `android/app/google-services.json`, and `firebase_options.dart`'s `android.appId` must all match — currently `raqamli.nazorat.hgt_mobile`. Likewise iOS: the Xcode `PRODUCT_BUNDLE_IDENTIFIER`, `firebase_options.dart`'s `iosBundleId`, and the Firebase Console iOS app's bundle id must match. After any package/bundle rename, re-run `flutterfire configure` (regenerates `firebase_options.dart`, `google-services.json`, and the iOS `GoogleService-Info.plist`). iOS push additionally needs an APNs key uploaded to Firebase + Push/Background-Modes capabilities in Xcode.

### Onboarding feature
`features/onboarding/` (clean arch, see `ONBOARDING_SPEC.md`) — a multi-step first-run flow shown inside the `faceVerificationRequired` branch when `SessionBloc.requiresOnboarding` is true (i.e. `StorageKeys.onboardingCompleted` not set). `OnboardingBloc` drives stepped widgets (`welcome → password → permissions → image_upload → face_verify → done`). The password step `POST`s `old_password`/`new_password`/`confirm_new_password` to `/v1/users/auth/change-password/` (`ApiConstants.setPassword`) using the RAM token (`skipRefresh`) — the "old password" is the login password held in `SessionBloc.pendingLoginPassword`; gate driven by `pendingIsPasswordChanged`. It reuses `GetProfileUseCase`/`UpdateFaceImageUseCase`/`ImagePickerService`. Onboarding completing persists the session (same path as face-verify) and flips the device-once flag. `ChangePasswordBloc` (in `profile/`) reuses `ChangePasswordUseCase` for later in-app password changes.

### Attendance feature (online + offline)
`features/attendance/` (clean arch). Online: `mark` (`POST /v1/attendance/attendance/`, FormData `event_type` ∈ check_in/lunch_start/lunch_end/check_out + `gps_latitude`/`gps_longitude` + `image` selfie), today/history/personal-stats GETs. `FaceVerifyBloc` is **universal** — the same bloc runs both the login face-gate and the attendance mark; mode chosen via `FaceStarted(mode)` / `AttendanceFaceMode(eventType, swipeTime)`. Home (`AttendanceBloc`) merges backend today-events with the offline pending queue for the swipe UI + badge. **Time logic is sacred — never change swipe timing / `created_at` derivation.**

> **Offline-first caching (cache-aside at `repository_impl`):** `ProfileCacheStore` + `AttendanceCacheStore` (today keyed by user+date; range/stats bounded LRU map) + `GeozoneCacheStore` wrap the repos — write cache on network success, read cache on `NetworkException`. Cleared on logout in `SessionBloc._clearAll`. Profile image is also saved as a **local file** via `FaceImageCacheService` (`<docs>/face_images/<userId>.jpg`) so it shows offline AND serves as the offline face-match reference. **Gotcha:** the avatar UI displays offline via `CachedNetworkImage`'s own `flutter_cache_manager` disk cache (keyed by URL), which is a *separate* cache from `FaceImageCacheService` — so `downloadAndStore()` pulls bytes through `DefaultCacheManager().getSingleFile(url)` first (same cache the avatar populates) before falling back to a direct Dio GET. A first online home visit is required to prime: `offline_secret` (HMAC key, secure storage) + reference face image + geozone cache.

> **Offline attendance mark:** when offline, `FaceVerifyBloc._enqueueOffline` runs the full block policy — secret present? geozone cache present? inside geofence (`GeofenceService` haversine)? face matches reference (`FaceMatchService`)? — then signs and enqueues. `created_at` = **swipe time** ISO8601 with local offset (NOT UTC); `signature = HMAC_SHA256(created_at, offline_secret)` lowercase hex (`HmacSigner`). Queue = lightweight JSON file `<docs>/offline_attendance/queue.json` + selfie JPGs (`OfflineAttendanceStore`, NOT Hive). `OfflineSyncService` listens to `connectivity_plus` + `SessionBloc` and drains on reconnect: 2xx → remove; network/401/429 → keep + retry later; 400 (bad signature/stale) or >24h old → drop. Backend HMAC contract documented in `mobile_offline_docs.md`. Offline face match = `tflite_flutter` + MobileFaceNet (`assets/models/mobilefacenet.tflite`, L2-normed embedding) with ML Kit for the face bbox; decision uses **cosine similarity** (`FaceMatchService.simThreshold = 0.5`). **EXIF gotcha:** ML Kit applies EXIF rotation on file read but `img.decodeImage` does not — so `FaceMatchService` `img.bakeOrientation()`s then re-runs detection on the baked temp JPG so bbox and crop share one coordinate frame. A debug-only diagnostic page (`face_match_diagnostic_page.dart`, kDebugMode FAB on home) compares two picked images live. The offline pipeline (camera + ML Kit + tflite native) **cannot run on Windows/web** — verify only on a real device.

## UI rules

- **Widgets:** minimize `Container`. Use `DecoratedBox` + `SizedBox` for styling and spacing/separation.
- **Dimensions:** `flutter_screenutil` is mandatory. Every size, padding, margin, radius, font size uses scaling extensions — `.w`, `.h`, `.r`, `.sp`. No raw logical pixels in layout. (Note: `core/extentions/size_extension.dart` also defines `.w`/`.h` on `num` — don't import it in UI files or it shadows screenutil; follow the login/profile files and import `flutter_screenutil`.)
- **Radius:** map to the Figma design tokens — input `radius-md` (8), button `radius-lg` (10), cards/sheets `radius-3xl` (22). Match Figma 1:1; don't invent arbitrary radii.
- **Responsiveness:** use `LayoutBuilder` + adaptive constraints for full responsiveness. Always guard text overflow (`maxLines`, `TextOverflow.ellipsis`, `Flexible`/`Expanded`). Components must degrade gracefully across screen sizes.
- **Typography:** style text via the extensions in `lib/core/extentions/text_extensions.dart` — chainable: `'label'.s(16.sp).w(600).c(color)`, plus `.a()` (align) and `.h()` (height). Default typeface is **Inter** (Figma `family/sans`), bundled as local static fonts (`pubspec.yaml` `fonts:`) and applied via `kBaseTextStyle` (`FontFamily.inter` from `core/gen/fonts.gen.dart`). Manrope/`GoogleFonts` were dropped — enforce Inter everywhere; never reach for `google_fonts`.
- **Reuse:** prefer existing custom widgets (`lib/core/widgets/`). New shared components must be modular, configurable, and parameterized for multiple call sites — not one-off.
- **Assets/icons:** reference only via the generated `Assets` class (`core/gen/assets.gen.dart`, flutter_gen) — never hardcode paths or `Icons.*` material glyphs for design icons. Render SVGs with a theme-token `colorFilter` (`Assets.icons.x.svg(colorFilter: ColorFilter.mode(colors.iconStrong, BlendMode.srcIn))`) so they adapt to light/dark. After adding files under `assets/`, regenerate with `dart run build_runner build --delete-conflicting-outputs`.

## Theme & color

- Dual-mode (light + dark) is required for every UI. Design both at draw time.
- **No raw hex / `Color(0x...)` in page or widget files.** Pull from theme tokens. Two token systems exist (both `ThemeExtension`s):
  - `AppColors` (`config/theme/app_colors.dart`) — current design-system tokens (background/accent/text/stroke/icon/error/success scales). Access: `AppColors.of(context).textStrong`. **Prefer this for new code.**
  - `ThemeColors` (`config/theme/theme_colors.dart`) — older palette, via `context.color` (`build_context_extension.dart`).
- Missing a color? Add a token to the relevant `ThemeExtension` (light + dark + `copyWith` + `lerp`) — never inline it.

## Localization (l10n)

Wired. `l10n.yaml` (template `app_uz.arb`, output `lib/l10n/app_localizations.dart`, `nullable-getter: false`). **Three locales**: `app_uz.arb` (latin, base), `app_uz_Cyrl.arb` (cyrillic — `Locale.fromSubtags(uz, Cyrl)`), `app_ru.arb`. Locale is **user-switchable** at runtime via the login language picker → `LocaleBloc` → `MaterialApp.locale` (persisted in `StorageKeys.languageCode`). Access via `AppLocalizations.of(context)`. Generated files (`app_localizations*.dart`) are build output — regenerate with `flutter gen-l10n` after editing `.arb`. Every new/redesigned screen: audit user-facing strings, reuse existing keys, append new keys to **all three** `.arb` bundles, then `flutter gen-l10n` — no hardcoded display strings. Blocs stay context-free: emit error/enum types, map to localized text in the widget layer.

## Git workflow

Three-branch strategy (see `CONTRIBUTING.md`): `dev` is the default trunk — all work enters via PR. Branch off `dev` as `feature/<desc>` or `bugfix/<desc>`. PR base `dev`, link issue with `Closes #N`. Promote `dev` → `prod` / `main` by PR. Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`).
