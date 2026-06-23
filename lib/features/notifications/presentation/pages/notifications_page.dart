import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/notification_bloc.dart';
import '../widgets/notification_tile.dart';

/// «Bildirishnomalar» ekrani (Figma 554:6176 / 554:7182).
///
/// Tepada orqaga tugmasi + sarlavha + «barchasini o‘qildi» tugmasi; ostida
/// sahifalanadigan ro‘yxat (pull-to-refresh + infinite scroll). Bildirishnoma
/// bosilganda o‘qilgan deb belgilanadi.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _scroll = ScrollController();
  StreamSubscription<RemoteMessage>? _pushSub;

  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(const NotificationsRequested());
    _scroll.addListener(_onScroll);

    // Yangi xabar signali (FCM old plan) — ro‘yxatni jim yangilaymiz. WS prepend
    // ham ishlaydi; bu ishonchli zaxira (dublikat id filtrlanadi).
    _pushSub = getIt<PushNotificationService>().messages.listen((_) {
      if (mounted) {
        context
            .read<NotificationBloc>()
            .add(const NotificationsSilentRefreshRequested());
      }
    });
  }

  @override
  void dispose() {
    _pushSub?.cancel();
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200.h) {
      context.read<NotificationBloc>().add(const NotificationsNextPageRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundBase,
      appBar: AppBar(
        backgroundColor: colors.backgroundBase,
        surfaceTintColor: colors.backgroundBase,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        // leadingWidth: 72.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: _CircleIconButton(
            icon: Assets.icons.icHugeiconsArrowLeftRound,
            background: colors.backgroundElevation2,
            iconColor: colors.iconStrong,
            iconSize: 20.r,
            onTap: () => context.pop(),
          ),
        ),
        title: l10n.notificationsTitle.s(18.sp).w(500).c(colors.textStrong).h(28 / 18),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            buildWhen: (p, c) => p.hasUnread != c.hasUnread,
            builder: (context, state) {
              if (!state.hasUnread) return SizedBox(width: 20.w);
              return Padding(
                padding: EdgeInsets.only(right: 20.w),
                child: _CircleIconButton(
                  icon: Assets.icons.icHugeiconsCheckList,
                  background: Colors.transparent,
                  iconColor: colors.iconStrong,
                  tooltip: l10n.notificationsMarkAllRead,
                  onTap: () => context
                      .read<NotificationBloc>()
                      .add(const NotificationsAllRead()),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) =>
            _Body(state: state, colors: colors, l10n: l10n, controller: _scroll),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.state,
    required this.colors,
    required this.l10n,
    required this.controller,
  });

  final NotificationState state;
  final AppColors colors;
  final AppLocalizations l10n;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    if (state.status == NotificationStatus.loading ||
        state.status == NotificationStatus.initial) {
      return Center(
        child: SizedBox(
          width: 28.r,
          height: 28.r,
          child: CircularProgressIndicator(
            strokeWidth: 2.5.r,
            valueColor: AlwaysStoppedAnimation<Color>(colors.accentSub),
          ),
        ),
      );
    }

    if (state.status == NotificationStatus.failure) {
      return _Centered(
        icon: Assets.icons.icHugeiconsNotification,
        text: state.errorKind == NotificationErrorKind.network
            ? l10n.networkError
            : l10n.notificationsError,
        colors: colors,
      );
    }

    if (state.isEmpty) {
      return _Centered(
        icon: Assets.icons.icHugeiconsNotification,
        text: l10n.notificationsEmpty,
        colors: colors,
      );
    }

    final locale = Localizations.localeOf(context);
    return RefreshIndicator(
      color: colors.accentSub,
      backgroundColor: colors.backgroundElevation1,
      onRefresh: () async {
        final bloc = context.read<NotificationBloc>();
        bloc.add(const NotificationsRequested());
        await bloc.stream.firstWhere(
          (s) => s.status != NotificationStatus.loading,
        );
      },
      child: ListView.separated(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
        itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Center(
                child: SizedBox(
                  width: 22.r,
                  height: 22.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.r,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.accentSub),
                  ),
                ),
              ),
            );
          }
          final item = state.items[index];
          return NotificationTile(
            notification: item,
            languageCode: locale.languageCode,
            scriptCode: locale.scriptCode,
            onTap: () => context
                .read<NotificationBloc>()
                .add(NotificationMarkedRead(item.id)),
          );
        },
      ),
    );
  }
}

/// Doira shaklidagi ikon tugma (header orqaga / barchasini o‘qish).
class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.onTap,
    this.tooltip,
    this.iconSize,
  });

  final SvgGenImage icon;
  final Color background;
  final Color iconColor;
  final VoidCallback onTap;
  final String? tooltip;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: background,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 40.w,
          height: 40.h,
          child: Center(
            child: icon.svg(
              width: iconSize ?? 24.r,
              height: iconSize ?? 24.r,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// Markazlashgan bo‘sh/xato holati (ikon + matn).
class _Centered extends StatelessWidget {
  const _Centered({required this.icon, required this.text, required this.colors});

  final SvgGenImage icon;
  final String text;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon.svg(
            width: 48.r,
            height: 48.r,
            colorFilter: ColorFilter.mode(colors.iconSoft, BlendMode.srcIn),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: text
                .s(14.sp)
                .w(400)
                .c(colors.textSub)
                .a(TextAlign.center)
                .copyWith(maxLines: 3, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
