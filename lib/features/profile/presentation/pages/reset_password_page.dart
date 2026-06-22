import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../onboarding/domain/entities/password_rule.dart';
import '../../../onboarding/presentation/widgets/password_rule_item.dart';
import '../bloc/change_password_bloc.dart';

/// «Parol o‘zgartirish» sahifasi (Figma 551‑15732 / 551‑15946).
///
/// Yuqorida fixed sarlavha (orqaga tugma + matn), pastda scroll qilinadigan
/// maydonlar: eski parol + yangi parol (jonli shartlar) + takrorlash. Hammasi
/// to‘g‘ri bo‘lganda pastda «Saqlash» tugmasi ko‘rinadi → `change-password`ga
/// yuboradi. Muvaffaqiyatda orqaga qaytadi va xabar ko‘rsatadi.
class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

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
    final bloc = context.read<ChangePasswordBloc>();

    return Scaffold(
      backgroundColor: colors.backgroundBase,
      body: SafeArea(
        child: BlocListener<ChangePasswordBloc, ChangePasswordState>(
          listenWhen: (p, c) => p.success != c.success,
          listener: (context, state) {
            if (state.success) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    backgroundColor: colors.successStrong,
                    content: l10n.cpwSuccess
                        .s(14.sp)
                        .w(500)
                        .c(colors.textWhite),
                  ),
                );
              context.pop();
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BackButton(onTap: () => context.pop()),
                    SizedBox(height: 20.h),
                    l10n.onbPasswordTitle
                        .s(24.sp)
                        .w(700)
                        .c(colors.textStrong)
                        .h(32 / 24)
                        .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
                    SizedBox(height: 6.h),
                    l10n.onbPasswordSubtitle
                        .s(14.sp)
                        .w(500)
                        .c(colors.textSub)
                        .h(20 / 14)
                        .copyWith(maxLines: 4, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Eski parol ─────────────────────────────────────────
                      BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
                        buildWhen: (p, c) => p.error != c.error,
                        builder: (context, state) => _PasswordField(
                          label: l10n.onbPasswordOldLabel,
                          hasError: state.error != ChangePasswordErrorKind.none,
                          onChanged: (v) =>
                              bloc.add(ChangePasswordOldChanged(v)),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // ── Yangi parol ────────────────────────────────────────
                      BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
                        buildWhen: (p, c) => p.error != c.error,
                        builder: (context, state) => _PasswordField(
                          label: l10n.onbPasswordLabel,
                          hasError: state.error != ChangePasswordErrorKind.none,
                          onChanged: (v) =>
                              bloc.add(ChangePasswordNewChanged(v)),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // ── Yangi parolni takrorlash ───────────────────────────
                      BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
                        buildWhen: (p, c) =>
                            p.error != c.error ||
                            p.newPassword != c.newPassword ||
                            p.confirmPassword != c.confirmPassword,
                        builder: (context, state) {
                          final mismatch = state.confirmPassword.isNotEmpty &&
                              state.newPassword != state.confirmPassword;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _PasswordField(
                                label: l10n.cpwConfirmLabel,
                                textInputAction: TextInputAction.done,
                                hasError: mismatch ||
                                    state.error != ChangePasswordErrorKind.none,
                                onChanged: (v) =>
                                    bloc.add(ChangePasswordConfirmChanged(v)),
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
                      SizedBox(height: 16.h),
                      // ── Parol shartlari (jonli) ────────────────────────────
                      BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
                        buildWhen: (p, c) =>
                            p.satisfiedRules != c.satisfiedRules,
                        builder: (context, state) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final rule in PasswordRule.values)
                              PasswordRuleItem(
                                label: _ruleLabel(l10n, rule),
                                satisfied: state.satisfiedRules.contains(rule),
                              ),
                          ],
                        ),
                      ),
                      const _ErrorText(),
                    ],
                  ),
                ),
              ),
              // ── Saqlash (shartlar to‘liq bo‘lganda) ──────────────────────
              BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
                buildWhen: (p, c) =>
                    p.canSubmit != c.canSubmit || p.submitting != c.submitting,
                builder: (context, state) {
                  if (!state.canSubmit && !state.submitting) {
                    return SizedBox(height: 8.h);
                  }
                  return Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
                    child: CustomButton(
                      label: l10n.cpwSave,
                      isLoading: state.submitting,
                      leading: Assets.icons.icLucideCheck.svg(
                        width: 20.r,
                        height: 20.r,
                        colorFilter: ColorFilter.mode(
                          colors.textWhite,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        bloc.add(const ChangePasswordSubmitted());
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dumaloq orqaga tugmasi (Figma — to‘q doira ichida chap o‘q).
class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: SizedBox(
          width: 40.r,
          height: 40.r,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.backgroundElevation2,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Assets.icons.icHugeiconsArrowLeftRound.svg(
                width: 20.r,
                height: 20.r,
                colorFilter: ColorFilter.mode(
                  colors.iconStrong,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Yorliq + parol kiritish maydoni (yashirish/ko‘rsatish tugmasi bilan).
class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.onChanged,
    this.hasError = false,
    this.textInputAction = TextInputAction.next,
  });

  final String label;
  final ValueChanged<String> onChanged;
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
          hintText: AppLocalizations.of(context).loginPasswordLabel,
          obscureText: true,
          showObscureToggle: true,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: textInputAction,
          backgroundColor: colors.backgroundBase,
          hasError: hasError,
          onChanged: onChanged,
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

/// Server / tarmoq xato matni.
class _ErrorText extends StatelessWidget {
  const _ErrorText();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
      buildWhen: (p, c) => p.error != c.error,
      builder: (context, state) {
        if (state.error == ChangePasswordErrorKind.none) {
          return SizedBox(height: 4.h);
        }
        final text = switch (state.error) {
          ChangePasswordErrorKind.network => l10n.networkError,
          _ => l10n.commonError,
        };
        return Padding(
          padding: EdgeInsets.only(top: 12.h),
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
