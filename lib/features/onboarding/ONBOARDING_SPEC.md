# Onboarding feature — build spec (shared by sub-agents)

Post-login mandatory setup, shown while `SessionStatus.faceVerificationRequired`.
Route `/onboarding` (already wired). A `PageView` with **forward-gating** (can swipe
back freely, cannot pass an incomplete step). Full-screen Figma gradient background.
Light + dark required. **No `Spacer`** — center content with `Expanded(child: Center(...))`
and pin the bottom button after it.

## Steps (built dynamically from login response)
1. welcome — always
2. permissions — always (location + camera; each button requests; both granted → continue)
3. password — only if `is_password_changed == false`
4. imageUpload — only if `face_image` empty/null
5. faceVerify — always (DONE — built already)
6. done — always (DONE — built already)

## Bloc API (already built — `presentation/bloc/onboarding_bloc.dart`)
`OnboardingBloc` / `OnboardingState`:
- `state.data` → `OnboardingData(accessToken, fullName, isPasswordChanged, loginPassword, faceImage, roleName)`
- `state.locationGranted`, `state.cameraGranted`
- `state.oldPassword` (login’dan oldindan), `state.newPassword`, `state.confirmPassword`,
  `state.passwordSubmitting`, `state.passwordChanged`, `state.passwordError` (`OnboardingErrorKind`)
- `state.satisfiedRules` → `Set<PasswordRule>`, `state.isNewPasswordStrong`,
  `state.passwordsMatch`, `state.canSubmitPassword`
- `state.pickedImagePath`, `state.imageUploading`, `state.imageUploaded`, `state.imageError`
- `state.canAdvanceCurrent`
Events to dispatch from UI:
- `OnboardingNextPressed()` — bottom "Davom etish" (advances if gate satisfied)
- `OnboardingPermissionRequested(OnboardingPermission.location|camera)`
- `OnboardingOldPasswordChanged(String)`, `OnboardingPasswordChanged(String)`,
  `OnboardingConfirmPasswordChanged(String)`,
  `OnboardingPasswordSubmitted()` (validates old+new+confirm, POSTs change-password, advances)
- `OnboardingImagePickRequested()` (picks from gallery + uploads)
`PasswordRule` enum (`domain/entities/password_rule.dart`): minLength, upperCase,
lowerCase, digit, special — `rule.isSatisfiedBy(value)`.

## Conventions (from CLAUDE.md — MANDATORY)
- `flutter_screenutil`: every size `.w/.h/.r/.sp`. Import `package:flutter_screenutil/flutter_screenutil.dart`.
- Text via `lib/core/extentions/text_extensions.dart`: `'x'.s(16.sp).w(600).c(color).a(align).h(height)`.
- Colors only from `AppColors.of(context)` (no raw hex). Theme tokens listed below.
- Icons only via `Assets.icons.*` (`core/gen/assets.gen.dart`), SVG with
  `colorFilter: ColorFilter.mode(colors.X, BlendMode.srcIn)` (except multicolor party icon).
- Minimize `Container` → `DecoratedBox` + `SizedBox`. Radii: input 8, button 10, card 22.
- Reuse `CustomButton` (`core/widgets/custom_button.dart`) — supports `gradient:` param.
  Onboarding primary buttons: `gradient: AppColors.onboardingActionGradient`.
- Reuse `CustomTextField` (`core/widgets/custom_text_field.dart`) for password input.
- All strings via `AppLocalizations.of(context)` — keys listed below (l10n agent adds them).
- Each step = its own file under `presentation/widgets/`, `const X({super.key})`,
  reads bloc via `context.read/watch<OnboardingBloc>()`.
- Content scrollable when needed (`SingleChildScrollView`) — keyboard safe (password).

## Icons available (assets.gen.dart)
- `icExclude` (brand logo), `icHugeiconsSecurityCheck` (shield-check, green),
- `icHugeiconsLocationShare` (GPS), `icHugeiconsCameraAdd` (camera/upload),
- `icEyeOpen`/`icEyeClose` (password — handled by CustomTextField),
- `icLucideScanFace`, `icHugeiconsParty`, `icArrowLeftLarge`, `icProfile`, `icUser`.

## Theme tokens (theme agent adds to AppColors; use via AppColors.of(context) / static)
- `onboardingBackgroundGradient(Brightness)` — full-screen bg (static).
- `onboardingActionGradient` — blue gradient for primary buttons (static const).
- existing: textStrong, textSub, white, accentSub, successPrimary, strokeSoft,
  backgroundElevation1, backgroundElevation1Alt, backgroundElevation2Alt, avatarPlaceholder.

## Per-step visual spec (light → dark mirrors via tokens)

### welcome_step.dart  (Figma 248-701 / 299-7763)
Centered column: brand logo (icExclude white on `AppColors.brandNavy` rounded box, ~36),
title `onbWelcomeTitle` (24/700 textStrong center), subtitle `onbWelcomeSubtitle`
(14/400 textSub center), then **ProfileSummaryCard**, bottom `CustomButton(onbContinue,
gradient)` → `OnboardingNextPressed()`.
ProfileSummaryCard (own file `profile_summary_card.dart`): rounded 22 translucent card
(`backgroundElevation1Alt` or white@0.5), Row[ avatar circle 44 (NetworkImage of
`data.faceImage` if present else initials of `data.fullName` on `avatarPlaceholder`),
name (15/700 textStrong) + role `data.roleName ?? onbRoleEmployee` (13/400 textSub),
trailing `icHugeiconsSecurityCheck` green ].

### permissions_step.dart  (Figma 256-1138 → 263-1232 ; dark 299-7801→7845)
Title `onbPermissionsTitle` (24/700 center), subtitle `onbPermissionsSubtitle` (14/400).
Two **PermissionTile** (own file `permission_tile.dart`): rounded 22 card, Row[ icon box
(white rounded, icon: location/camera; green when granted), texts (title 15/600 + desc
13/400 textSub), trailing: if NOT granted a dark pill button `onbGrant` (bg textStrong,
text white) → `OnboardingPermissionRequested(kind)`; if granted no button ].
Tiles: location = `onbPermLocationTitle`/`onbPermLocationDesc` + `icHugeiconsLocationShare`;
camera = `onbPermCameraTitle`/`onbPermCameraDesc` + `icHugeiconsCameraAdd`.
Bottom `CustomButton(onbContinue, gradient)` → `OnboardingNextPressed()` shown only when
`state.locationGranted && state.cameraGranted` (else `SizedBox(height:52.h)`).

### password_step.dart  (Figma 263-1333 / 290-749 / 290-822 ; dark 299-7938)
Left-aligned. Title `onbPasswordTitle` (24/700 center), subtitle `onbPasswordSubtitle`
(14/400 center). Label `onbPasswordLabel` (14/500). `CustomTextField` (obscure toggle on,
`onChanged → OnboardingPasswordChanged`, hint `onbPasswordLabel`). Then rules list — one
**PasswordRuleItem** (own file `password_rule_item.dart`) per `PasswordRule.values`: Row[
small dot (green `successPrimary` if `state.satisfiedRules.contains(rule)` else
`strokeStrong`), label ]. Rule labels: `onbRuleMinLength`, `onbRuleUpper`, `onbRuleLower`,
`onbRuleDigit`, `onbRuleSpecial`. Bottom `CustomButton(onbContinue, gradient,
isLoading: state.passwordSubmitting)` → `OnboardingPasswordSubmitted()` — shown only when
`state.isPasswordStrong` (else `SizedBox(height:52.h)`). Content in SingleChildScrollView.

### image_upload_step.dart  (Figma 290-916 → 290-1017 ; dark 299-8037)
Centered. Title `onbImageTitle` (24/700 center), subtitle `onbImageSubtitle` (14/400).
Big circle ~180 (`avatarPlaceholder` bg) tappable → `OnboardingImagePickRequested()`:
if `state.pickedImagePath != null` show `Image.file` cover with dashed green border
(use a simple `successPrimary` ring), else center column `icHugeiconsCameraAdd` (iconSoft)
+ `onbImageUpload` (13/400 textSub). Show `CircularProgressIndicator` overlay while
`state.imageUploading`. Below circle a pill chip `onbImageHint` with `icLucideScanFace`.
Bottom `CustomButton(onbContinue, gradient)` → `OnboardingNextPressed()` shown only when
`state.imageUploaded` (else `SizedBox(height:52.h)`).

All four steps: outer `Padding(EdgeInsets.fromLTRB(20.w,8.h,20.w,24.h))`, then
`Column[ SizedBox(12.h), title, sub, Expanded(child: Center(child: <body>)), bottomButton ]`.
(password step body wrapped in SingleChildScrollView instead of Center).
