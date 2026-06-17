import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/bloc/session_bloc.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';

/// Animated brand splash shown while [SessionBloc] resolves the initial session.
///
/// Theme-aware: light mode shows the light-blue brand background + navy logo
/// (Figma 221:689 → 221:814), dark mode the dark background + near-white logo
/// (Figma 296:2865 → 296:2873). The logo stays fixed in place while the
/// «Davomat» wordmark fades + slides in just beneath it — the only difference
/// between each pair of frames. The native splash is now a plain brand color,
/// so this screen owns the full visual. The router guard moves off once the
/// session status is known; [SessionBloc] holds it briefly so the reveal can
/// finish.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  /// Brand wordmark — product name, intentionally not localized.
  static const String _wordmark = 'Davomat';

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.45),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _runRevealThenResolve();
  }

  /// Plays the wordmark reveal, holds briefly so it can be read, then asks
  /// [SessionBloc] to resolve the session — which lets the router guard leave
  /// the splash. Driving resolution from here (rather than at bootstrap)
  /// guarantees the animation is visible regardless of engine warm-up.
  Future<void> _runRevealThenResolve() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    await _controller.forward();
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    context.read<SessionBloc>().add(const SessionStarted());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme-swapped assets: dark gets its own background + light logo tint.
    final background = isDark
        ? Assets.images.splashBackgroundImageDark
        : Assets.images.splashBackgroundImage;
    final logoTint = isDark ? colors.textStrong : AppColors.brandNavy;

    return Scaffold(
      backgroundColor: colors.backgroundBase,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Logo is centered; the wordmark is pinned just below it so the logo
          // never shifts as text appears.
          final centerY = constraints.maxHeight / 2;
          final logoSize = 64.r;

          return Stack(
            fit: StackFit.expand,
            children: [
              background.image(fit: BoxFit.cover, alignment: Alignment.center),
              Center(
                child: Assets.icons.icSplashLogoDark.svg(
                  width: logoSize,
                  height: logoSize,
                  colorFilter: ColorFilter.mode(logoTint, BlendMode.srcIn),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: centerY + logoSize / 2 + 8.h,
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Center(
                      child: _wordmark
                          .s(30.sp)
                          .w(500)
                          .c(colors.textStrong)
                          .copyWith(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
