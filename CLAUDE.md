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
dart run build_runner build --delete-conflicting-outputs   # codegen (flutter_gen assets)
```

After any change: `flutter analyze lib` must report **0 issues** (one pre-existing info in `core/usecases/usecase.dart` aside).

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
- Flow: `splash` (status `unknown`) → `login` (no token) → `faceVerify` (`faceVerificationRequired`: logged in, face pending) → `home` (face verified). **No PIN, no role-select** — abandoned. `checkCode` (attendance) route still exists but is **not** in the guard chain.
- Add a screen: declare in `routes.dart` → add `GoRoute` in `coordinator.dart` → it is auto-protected by the guard (anything not splash/login/faceVerify requires full auth).

### State management — BLoC only
Use the **BLoC** pattern (events → states) for all feature state. **Cubits are not permitted** anywhere. Provide blocs via `BlocProvider` / `getIt`; UI reads with `context.read`/`BlocBuilder`/`BlocListener`.
> App-wide session/auth state lives in the app-level `SessionBloc` (`lib/app/bloc/session_bloc.dart`) — it drives the router guard. Statuses: `unknown` / `unauthenticated` / `faceVerificationRequired` / `authenticated`. App-level `ThemeBloc` (`bloc/theme/`) and `LocaleBloc` (`bloc/locale/`) drive `MaterialApp.themeMode` + `locale`. No cubits remain.

### Networking
`Dio` built in `injection_container` (`DioFactory.create()` from `core/network/`), wrapped by `DioClient`. Base URL `https://hkk-backend.raqamlinazorat.uz/api`; endpoints under `/v1/users/auth/` live in `core/constants/api_constants.dart`. Interceptors, in order: `AuthInterceptor` (attaches `Bearer` from `TokenService`) → `RefreshInterceptor` → `LoggingInterceptor`. The `RefreshInterceptor` is a `QueuedInterceptor`: on a 401 from a **non-auth** path it refreshes the access token via a separate interceptor-free `Dio` and replays the request; on refresh failure it fires `SessionExpired`. It **skips** `login`, `refresh`, **and `verify-face`** (verify-face uses the not-yet-persisted RAM token, so a refresh loop would be meaningless). Data sources tolerate both raw SimpleJWT (`{ access, refresh }`) and an enveloped `{ data, error, success }` response, mapping HTTP/business errors → typed `Exception`s (`core/error/`); repos map those to `Failure`s, blocs map `Failure`s to **error enums**, widgets localize.

### Auth + face-verify flow
- Login API field is **`full_name`** (+ `password`); UI labels it "Login". `LoginBloc` returns `AuthTokens` and emits them — it does **not** persist. 429 → `Timer.periodic` MM:SS countdown (`LoginErrorKind.blocked`); 401 → `invalid` (red field borders).
- **Tokens are held in RAM** (`SessionBloc._pendingAccess/_pendingRefresh/_pendingFullName`) after `SessionLoginSucceeded`, status → `faceVerificationRequired`. They are persisted **only** on `SessionFaceVerified` (after a successful `verify-face`). So killing the app mid-face → relaunch → back to login.
- Face step (`features/auth/presentation/face/`): `FaceVerifyBloc` runs `camera` preview + `google_mlkit_face_detection` on the image stream; a stable face auto-captures a selfie (`takePicture`) and POSTs it as **FormData `image` file** to `/v1/users/auth/verify-face/` with the RAM access token as manual `Bearer`. Circle border color = state (blue scan / green success / red fail). 2xx → `SessionFaceVerified`.
- On relaunch with a saved token (`SessionStarted`) → straight to `authenticated`/home (no re-login, no re-face).

## UI rules

- **Widgets:** minimize `Container`. Use `DecoratedBox` + `SizedBox` for styling and spacing/separation.
- **Dimensions:** `flutter_screenutil` is mandatory. Every size, padding, margin, radius, font size uses scaling extensions — `.w`, `.h`, `.r`, `.sp`. No raw logical pixels in layout.
- **Responsiveness:** use `LayoutBuilder` + adaptive constraints for full responsiveness. Always guard text overflow (`maxLines`, `TextOverflow.ellipsis`, `Flexible`/`Expanded`). Components must degrade gracefully across screen sizes.
- **Typography:** style text via the extensions in `lib/core/extentions/text_extensions.dart` — chainable: `'label'.s(16.sp).w(600).c(color)`, plus `.a()` (align) and `.h()` (height). Default typeface is `GoogleFonts.manrope` (already the fallback inside those extensions); enforce Manrope everywhere.
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
