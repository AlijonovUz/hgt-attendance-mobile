import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/password_rule.dart';
import '../bloc/onboarding_bloc.dart';
import 'onboarding_action_button.dart';
import 'password_rule_item.dart';

/// Onboarding «password» bosqichi (Figma 263‑1333): eski parol (login’dan
/// oldindan), yangi parol + jonli shartlar ro‘yxati, va yangi parolni tasdiqlash.
/// Hammasi to‘g‘ri (eski kiritilgan, yangisi kuchli, tasdiq mos) bo‘lganda
/// «Davom etish» tugmasi ko‘rinadi → `change-password`ga yuboradi. Klaviatura
/// xavfsiz (SingleChildScrollView).
class PasswordStep extends StatelessWidget {
  const PasswordStep({super.key});

  /// Shart matnini l10n’dan oladi.
  String _ruleLabel(AppLocalizations l10n, PasswordRule rule) => switch (rule) {
    PasswordRule.minLength => l10n.onbRuleMinLength,
    PasswordRule.upperCase => l10n.onbRuleUpper,
    PasswordRule.lowerCase => l10n.onbRuleLower,
    PasswordRule.digit => l10n.onbRuleDigit,
    PasswordRule.special => l10n.onbRuleSpecial,
  };

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<OnboardingBloc>();
    // Login’da kiritilgan parol — «eski parol» maydoniga oldindan (bloc holatida
    // `OnboardingStarted`da o‘rnatilgan).
    final oldInitial = bloc.state.oldPassword;

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 12.h),
          l10n.onbPasswordTitle
              .s(24.sp)
              .w(700)
              .c(colors.textStrong)
              .a(TextAlign.center)
              .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
          SizedBox(height: 2.h),
          l10n.onbPasswordSubtitle
              .s(14.sp)
              .w(500)
              .c(colors.textSub)
              .h(20 / 14)
              .a(TextAlign.center)
              .copyWith(maxLines: 4, overflow: TextOverflow.ellipsis),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Eski parol (login’dan oldindan) ────────────────────────
                  BlocBuilder<OnboardingBloc, OnboardingState>(
                    buildWhen: (p, c) => p.passwordError != c.passwordError,
                    builder: (context, state) => _PasswordField(
                      label: l10n.onbPasswordOldLabel,
                      initialValue: oldInitial,
                      hasError: state.passwordError != OnboardingErrorKind.none,
                      onChanged: (v) =>
                          bloc.add(OnboardingOldPasswordChanged(v)),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // ── Yangi parol ────────────────────────────────────────────
                  BlocBuilder<OnboardingBloc, OnboardingState>(
                    buildWhen: (p, c) => p.passwordError != c.passwordError,
                    builder: (context, state) => _PasswordField(
                      label: l10n.onbPasswordLabel,
                      hasError: state.passwordError != OnboardingErrorKind.none,
                      onChanged: (v) => bloc.add(OnboardingPasswordChanged(v)),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // ── Yangi parolni tasdiqlash ───────────────────────────────
                  BlocBuilder<OnboardingBloc, OnboardingState>(
                    buildWhen: (p, c) =>
                        p.passwordError != c.passwordError ||
                        p.newPassword != c.newPassword ||
                        p.confirmPassword != c.confirmPassword,
                    builder: (context, state) {
                      final mismatch =
                          state.confirmPassword.isNotEmpty &&
                          state.newPassword != state.confirmPassword;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _PasswordField(
                            label: l10n.onbPasswordConfirmLabel,
                            textInputAction: TextInputAction.done,
                            hasError:
                                mismatch ||
                                state.passwordError != OnboardingErrorKind.none,
                            onChanged: (v) =>
                                bloc.add(OnboardingConfirmPasswordChanged(v)),
                          ),
                          if (mismatch)
                            Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: l10n.onbPasswordMismatch
                                  .s(13.sp)
                                  .w(400)
                                  .c(colors.errorStrong)
                                  .h(18 / 13)
                                  .copyWith(
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                            ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 12.h),
                  // ── Parol shartlari (Figma: maydonlardan keyin) ────────────
                  BlocBuilder<OnboardingBloc, OnboardingState>(
                    buildWhen: (p, c) => p.satisfiedRules != c.satisfiedRules,
                    builder: (context, state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final rule in PasswordRule.values)
                            PasswordRuleItem(
                              label: _ruleLabel(l10n, rule),
                              satisfied: state.satisfiedRules.contains(rule),
                            ),
                        ],
                      );
                    },
                  ),
                  const _ErrorText(),
                ],
              ),
            ),
          ),
          // Tugma ko‘rinmaganda joy ham egallamasligi kerak (klaviatura ostida
          // bo‘sh band qolmaydi) — shu sabab `SizedBox.shrink`.
          BlocBuilder<OnboardingBloc, OnboardingState>(
            buildWhen: (p, c) =>
                p.canSubmitPassword != c.canSubmitPassword ||
                p.passwordSubmitting != c.passwordSubmitting,
            builder: (context, state) {
              if (!state.canSubmitPassword && !state.passwordSubmitting) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: OnboardingActionButton(
                  label: l10n.onbContinue,
                  isLoading: state.passwordSubmitting,
                  onPressed: () {
                    // Keyingi bosqichga o‘tishdan oldin klaviaturani yopamiz.
                    FocusScope.of(context).unfocus();
                    bloc.add(const OnboardingPasswordSubmitted());
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Yorliq + parol kiritish maydoni (yashirish/ko‘rsatish tugmasi bilan). Uchala
/// parol maydoni shu komponentdan foydalanadi (DRY).
class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.onChanged,
    this.initialValue,
    this.hasError = false,
    this.textInputAction = TextInputAction.next,
  });

  final String label;
  final ValueChanged<String> onChanged;
  final String? initialValue;
  final bool hasError;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label.s(14.sp).w(500).c(colors.textStrong).h(20 / 14),
        SizedBox(height: 6.h),
        CustomTextField(
          hintText: label,
          initialValue: initialValue,
          obscureText: true,
          showObscureToggle: true,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: textInputAction,
          backgroundColor: colors.backgroundBase,
          hasError: hasError,
          onChanged: onChanged,
          // «Next» → keyingi maydonga fokus; «Done» → klaviaturani yopadi.
          onSubmitted: (_) {
            if (textInputAction == TextInputAction.done) {
              FocusScope.of(context).unfocus();
            } else {
              FocusScope.of(context).nextFocus();
            }
          },
        ),
      ],
    );
  }
}

/// Parol bosqichidagi server / tarmoq xato matni.
class _ErrorText extends StatelessWidget {
  const _ErrorText();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<OnboardingBloc, OnboardingState>(
      buildWhen: (p, c) => p.passwordError != c.passwordError,
      builder: (context, state) {
        if (state.passwordError == OnboardingErrorKind.none) {
          return SizedBox(height: 4.h);
        }
        final text = switch (state.passwordError) {
          OnboardingErrorKind.network => l10n.networkError,
          _ => l10n.commonError,
        };
        return Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: text
              .s(13.sp)
              .w(400)
              .c(colors.errorStrong)
              .h(18 / 13)
              .copyWith(maxLines: 3, overflow: TextOverflow.ellipsis),
        );
      },
    );
  }
}
