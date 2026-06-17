import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/bloc/session_bloc.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/onboarding_data.dart';
import '../bloc/onboarding_bloc.dart';
import '../widgets/face_verify_step.dart';
import '../widgets/image_upload_step.dart';
import '../widgets/onboarding_done_step.dart';
import '../widgets/onboarding_progress.dart';
import '../widgets/password_step.dart';
import '../widgets/permissions_step.dart';
import '../widgets/welcome_step.dart';

/// Login’dan keyingi majburiy onboarding oqimi (PageView).
///
/// Bosqichlar login javobidan tuziladi; har bir bosqichning «gate»i yopilmaguncha
/// oldinga (qo‘lda ham, tugma bilan ham) o‘tib bo‘lmaydi. Fon — Figma gradienti
/// ([AppColors.onboardingBackgroundGradient]); yakuniy «done» bosqichida tepa
/// boshqaruv (orqaga + progress) yashiriladi.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionBloc>();
    return BlocProvider<OnboardingBloc>(
      create: (_) => getIt<OnboardingBloc>()
        ..add(
          OnboardingStarted(
            OnboardingData(
              accessToken: session.pendingAccessToken ?? '',
              fullName: session.pendingFullName ?? '',
              isPasswordChanged: session.pendingIsPasswordChanged,
              loginPassword: session.pendingLoginPassword ?? '',
              faceImage: session.pendingFaceImage,
            ),
          ),
        ),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final _controller = PageController();

  /// Eng katta ochiq indeks — `_GatedPagePhysics` shu qiymatni jonli o‘qiydi.
  /// Physics obyekti `ScrollPosition`ga bir marta biriktiriladi va Flutter uni
  /// faqat physics `runtimeType` o‘zgarsa qayta quradi; shu sabab `int` emas,
  /// notifier uzatamiz — aks holda boshlang‘ich `0` qotib qolib, oldinga surib
  /// (yoki `animateToPage` bilan) birinchi bosqichdan o‘tib bo‘lmaydi.
  final ValueNotifier<int> _maxUnlocked = ValueNotifier<int>(0);

  @override
  void dispose() {
    _controller.dispose();
    _maxUnlocked.dispose();
    super.dispose();
  }

  void _syncPage(int index) {
    if (!_controller.hasClients) return;
    final current = _controller.page?.round() ?? _controller.initialPage;
    if (current == index) return;
    // Bosqich almashganda ochiq klaviaturani yopamiz (parol → yuz o‘tishida
    // klaviatura osilib qolmasin).
    FocusManager.instance.primaryFocus?.unfocus();
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  /// Orqaga: bosqich > 0 bo‘lsa avvalgi bosqichga qaytadi; 0-bosqichda onboarding
  /// bekor qilinadi (`SessionLogoutRequested`) — RAM’dagi pending login tozalanib,
  /// guard avtomatik login’ga yo‘naltiradi. Tizim (apparat/imo-ishora) «orqaga»si
  /// ham shu yo‘ldan yuradi, shu sabab ilovadan chiqib ketmaydi.
  void _handleBack() {
    final state = context.read<OnboardingBloc>().state;
    if (state.currentIndex > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.read<SessionBloc>().add(const SessionLogoutRequested());
    }
  }

  Widget _stepWidget(OnboardingStep step) => switch (step) {
    OnboardingStep.welcome => const WelcomeStep(),
    OnboardingStep.permissions => const PermissionsStep(),
    OnboardingStep.password => const PasswordStep(),
    OnboardingStep.imageUpload => const ImageUploadStep(),
    OnboardingStep.faceVerify => const FaceVerifyStep(),
    OnboardingStep.done => const OnboardingDoneStep(),
  };

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final brightness = Theme.of(context).brightness;

    // Tizim «orqaga»sini ushlaymiz: standart pop ilovadan chiqarib yuboradi
    // (login → onboarding guard `redirect` bilan o‘tgani uchun back-stack yo‘q).
    // O‘rniga bosqichlar bo‘ylab orqaga, 0-bosqichda esa login’ga qaytamiz.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: colors.backgroundBase,
        // Klaviatura ochilganda body kichrayadi — parol bosqichidagi maydonlar
        // (ayniqsa «tasdiqlash») klaviatura tepasiga suriladi. Boshqa bosqichlarda
        // matn kiritish yo‘q, shu sabab inset 0 — hech narsa o‘zgarmaydi.
        resizeToAvoidBottomInset: true,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.onboardingBackgroundGradient(brightness),
          ),
          child: BlocConsumer<OnboardingBloc, OnboardingState>(
            listenWhen: (p, c) =>
                p.currentIndex != c.currentIndex ||
                p.maxUnlockedIndex != c.maxUnlockedIndex,
            listener: (context, state) {
              _maxUnlocked.value = state.maxUnlockedIndex;
              _syncPage(state.currentIndex);
            },
            builder: (context, state) {
              return SafeArea(
                child: Column(
                  children: [
                    // Tepa boshqaruv — yakuniy bosqichda yashiriladi.
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: state.showChrome
                          ? _TopChrome(
                              key: const ValueKey('chrome'),
                              total: state.progressTotal,
                              index: state.progressIndex,
                              onBack: _handleBack,
                            )
                          : const SizedBox.shrink(key: ValueKey('no-chrome')),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _controller,
                        physics: _GatedPagePhysics(
                          maxIndexListenable: _maxUnlocked,
                          parent: const BouncingScrollPhysics(),
                        ),
                        itemCount: state.steps.length,
                        onPageChanged: (i) => context
                            .read<OnboardingBloc>()
                            .add(OnboardingPageSettled(i)),
                        itemBuilder: (context, i) =>
                            _stepWidget(state.steps[i]),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Tepa qator: orqaga tugmasi (chap, doimo ko‘rinadi) + progress (markaz).
class _TopChrome extends StatelessWidget {
  const _TopChrome({
    super.key,
    required this.total,
    required this.index,
    required this.onBack,
  });

  final int total;
  final int index;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
      child: SizedBox(
        height: 44.r,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _BackButton(colors: colors, onTap: onBack),
            ),
            OnboardingProgress(total: total, index: index),
          ],
        ),
      ),
    );
  }
}

/// Orqaga tugmasi — Figma (299:6098) bo‘yicha oddiy chevron (foni yo‘q), rangi
/// mavzuga moslanadi (`iconStrong`).
class _BackButton extends StatelessWidget {
  const _BackButton({required this.colors, required this.onTap});

  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 40.r,
        height: 40.r,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.white,
            borderRadius: BorderRadiusGeometry.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Assets.icons.icHugeiconsArrowLeftRound.svg(
                // width: 24.r,
                // height: 24.r,
                // colorFilter: ColorFilter.mode(colors.iconStrong, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// PageView fizikasi — ochiq indeksdan oldinga surishni bloklaydi (orqaga erkin).
/// Gate yopilmaguncha keyingi sahifaga qo‘lda o‘tib bo‘lmaydi.
///
/// Chegara `int` emas, [maxIndexListenable] orqali jonli o‘qiladi: physics
/// `ScrollPosition`ga bir marta biriktirilib qotib qoladi, shu sabab qiymat
/// keyin o‘zgarsa ham (masalan, bosqich ochilganda) shu obyekt yangisini ko‘radi.
class _GatedPagePhysics extends ScrollPhysics {
  const _GatedPagePhysics({required this.maxIndexListenable, super.parent});

  final ValueListenable<int> maxIndexListenable;

  @override
  _GatedPagePhysics applyTo(ScrollPhysics? ancestor) => _GatedPagePhysics(
    maxIndexListenable: maxIndexListenable,
    parent: buildParent(ancestor),
  );

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    final maxOffset = maxIndexListenable.value * position.viewportDimension;
    // Oldinga (maxOffset’dan o‘tishga) ruxsat yo‘q.
    if (value > maxOffset && position.pixels <= maxOffset) {
      return value - maxOffset;
    }
    if (value > maxOffset && position.pixels > maxOffset) {
      return value - position.pixels;
    }
    return super.applyBoundaryConditions(position, value);
  }
}
