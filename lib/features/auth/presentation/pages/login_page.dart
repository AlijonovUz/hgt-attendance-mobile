import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/bloc/session_bloc.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/language_picker.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/login_bloc.dart';

/// «Davomat» login sahifasi — yangi dizayn (gradient header, til + tema kontrol,
/// xato/blok holatlari). Yuz tasdig‘i navbatdagi bosqich — navigatsiya guard
/// orqali `SessionBloc` holatidan kelib chiqadi.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (_) => getIt<LoginBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<LoginBloc>().add(const LoginSubmitted());
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: colors.backgroundBase,
      resizeToAvoidBottomInset: true,
      body: BlocListener<LoginBloc, LoginState>(
        listenWhen: (p, c) => p.status != c.status,
        listener: (context, state) {
          if (state.status == LoginStatus.success &&
              state.accessToken != null) {
            final responseName = state.responseFullName?.trim() ?? '';
            context.read<SessionBloc>().add(
              SessionLoginSucceeded(
                accessToken: state.accessToken!,
                refreshToken: state.refreshToken ?? '',
                fullName: responseName.isNotEmpty
                    ? responseName
                    : state.fullName.trim(),
                loginPassword: state.password,
                faceImage: state.faceImage,
                isPasswordChanged: state.isPasswordChanged,
              ),
            );
          }
        },
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 340.h,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.loginHeaderGradient(brightness),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 32.h,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Tepa qator: brend (chap) + til tanlash (o‘ng).
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [_Brand(), LanguagePicker()],
                            ),
                            // Markaziy blok: sarlavha + forma — bo‘sh joyda
                            // vertikal markazda (Figma kabi), Spacersiz.
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const _TitleBlock(),
                                    SizedBox(height: 28.h),
                                    _Form(
                                      colors: colors,
                                      loginController: _loginController,
                                      passwordController: _passwordController,
                                      onSubmit: _submit,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tepa brend bloki: logotip + «Davomat».
class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8.w,
      children: [
        Assets.icons.icExclude.svg(
          width: 32.w,
          height: 32.h,
          colorFilter: ColorFilter.mode(colors.textWhite, BlendMode.srcIn),
        ),
        l10n.appName.s(18.sp).w(600).c(colors.textStrong),
      ],
    );
  }
}

/// Markazlashgan sarlavha + tavsif.
class _TitleBlock extends StatelessWidget {
  const _TitleBlock();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        l10n.loginTitle
            .s(24.sp)
            .w(700)
            .c(colors.textStrong)
            .a(TextAlign.center)
            .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
        SizedBox(height: 8.h),
        l10n.loginSubtitle
            .s(14.sp)
            .w(400)
            .c(colors.textSub)
            .h(20 / 14)
            .a(TextAlign.center)
            .copyWith(maxLines: 3, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

/// Login formasi: maydonlar + xato/blok + tugma.
class _Form extends StatelessWidget {
  const _Form({
    required this.colors,
    required this.loginController,
    required this.passwordController,
    required this.onSubmit,
  });

  final AppColors colors;
  final TextEditingController loginController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LoginBloc>();
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<LoginBloc, LoginState>(
          buildWhen: (p, c) => p.errorKind != c.errorKind,
          builder: (context, state) {
            final hasFieldError = state.errorKind == LoginErrorKind.invalid;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label(l10n.loginLoginLabel, colors: colors),
                SizedBox(height: 6.h),
                CustomTextField(
                  controller: loginController,
                  hintText: l10n.loginFullNameHint,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  hasError: hasFieldError,
                  backgroundColor: colors.backgroundBase,
                  onChanged: (v) => bloc.add(LoginFullNameChanged(v)),
                  // «Next» → parol maydoniga fokus.
                  onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                ),
                SizedBox(height: 14.h),
                _Label(l10n.loginPasswordLabel, colors: colors),
                SizedBox(height: 6.h),
                CustomTextField(
                  controller: passwordController,
                  hintText: l10n.loginPasswordLabel,
                  obscureText: true,
                  showObscureToggle: true,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.visiblePassword,
                  hasError: hasFieldError,
                  backgroundColor: colors.backgroundBase,
                  onChanged: (v) => bloc.add(LoginPasswordChanged(v)),
                  onSubmitted: (_) => onSubmit(),
                ),
              ],
            );
          },
        ),
        const _ErrorArea(),
        SizedBox(height: 20.h),
        BlocBuilder<LoginBloc, LoginState>(
          buildWhen: (p, c) =>
              p.canSubmit != c.canSubmit || p.isLoading != c.isLoading,
          builder: (context, state) {
            return CustomButton(
              label: l10n.loginButton,
              enabled: state.canSubmit,
              isLoading: state.isLoading,
              onPressed: onSubmit,
            );
          },
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, {required this.colors});

  final String text;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return text.s(14.sp).w(500).c(colors.textStrong).h(20 / 14);
  }
}

/// Xato matni (invalid/network/server) yoki blok kartasi.
class _ErrorArea extends StatelessWidget {
  const _ErrorArea();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (p, c) =>
          p.errorKind != c.errorKind ||
          p.errorText != c.errorText ||
          p.blockedSeconds != c.blockedSeconds,
      builder: (context, state) {
        if (!state.hasError) return SizedBox(height: 4.h);

        if (state.errorKind == LoginErrorKind.blocked) {
          return Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: _BlockedCard(state: state, colors: colors, l10n: l10n),
          );
        }

        final text = switch (state.errorKind) {
          LoginErrorKind.network => l10n.networkError,
          // Backend `errorMsg`i bo‘lsa to‘g‘ridan-to‘g‘ri ko‘rsatamiz; aks holda
          // mobil l10n fallback (urinishlar soni bilan).
          LoginErrorKind.invalid =>
            state.errorText ??
                '*${l10n.loginInvalidCredentials} '
                    '${l10n.loginAttemptsRemaining(state.remainingAttempts)}',
          LoginErrorKind.server => state.errorText ?? l10n.commonError,
          _ => '',
        };

        return Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: text
              .s(14.sp)
              .w(400)
              .c(colors.errorStrong)
              .h(20 / 14)
              .copyWith(maxLines: 3, overflow: TextOverflow.ellipsis),
        );
      },
    );
  }
}

/// «Hisob vaqtincha bloklandi» kartasi + jonli MM:SS sanagich.
class _BlockedCard extends StatelessWidget {
  const _BlockedCard({
    required this.state,
    required this.colors,
    required this.l10n,
  });

  final LoginState state;
  final AppColors colors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: colors.strokeSub),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 32.r,
              height: 32.r,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.backgroundElevation2,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Center(
                  child: Assets.icons.icLucideShieldAlert.svg(
                    width: 16.r,
                    height: 16.r,
                    colorFilter: ColorFilter.mode(
                      colors.iconStrong,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  l10n.loginBlockedTitle
                      .s(14.sp)
                      .w(500)
                      .c(colors.textStrong)
                      .h(20 / 14)
                      .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4.h),
                  l10n
                      .loginBlockedBody(
                        LoginState.maxAttempts,
                        state.blockedMinutes,
                      )
                      .s(12.sp)
                      .w(400)
                      .c(colors.textSub)
                      .h(16 / 12)
                      .copyWith(maxLines: 4, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      l10n.loginBlockedRetryLabel
                          .s(14.sp)
                          .w(500)
                          .c(colors.textSub),
                      SizedBox(width: 6.w),
                      state.blockedClock
                          .s(14.sp)
                          .w(700)
                          .c(AppColors.warningStrong),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
