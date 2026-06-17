import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/user_avatar.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/face/bloc/face_flow_mode.dart';
import '../../../auth/presentation/face/bloc/face_verify_bloc.dart';
import '../../../auth/presentation/face/widgets/face_verify_view.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../domain/entities/attendance_event_type.dart';

/// Davomat yuz-tekshiruvi ekrani (asosiy ekrandan push qilinadi). Universal
/// [FaceVerifyView]ni [AttendanceFaceMode]da ishlatadi: kamera + GPS bilan
/// selfie olinib `POST /v1/attendance/attendance/` yuboriladi; 2xx →
/// `Navigator.pop(true)` (asosiy ekran bosqichni belgilab profilni qayta GET).
class AttendanceFacePage extends StatelessWidget {
  const AttendanceFacePage({super.key, required this.eventType});

  final AttendanceEventType eventType;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FaceVerifyBloc>(
          create: (_) => getIt<FaceVerifyBloc>()
            ..add(FaceStarted(AttendanceFaceMode(eventType))),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => getIt<ProfileBloc>()..add(const ProfileRequested()),
        ),
      ],
      child: FaceVerifyView(
        onSuccess: (context) => Navigator.of(context).pop(true),
        nameSection: const _ProfileName(),
        imageSection: const _ProfileAvatar(),
      ),
    );
  }
}

/// Karta avatari — davomatda `ProfileBloc`dan o‘qiladi.
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (p, c) => p.profile?.faceImage != c.profile?.faceImage,
      builder: (context, state) =>
          UserAvatar(faceImage: state.profile?.faceImage, size: 44.r),
    );
  }
}

/// Karta ismi — davomatda `ProfileBloc`dan o‘qiladi.
class _ProfileName extends StatelessWidget {
  const _ProfileName();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (p, c) => p.profile?.fullName != c.profile?.fullName,
      builder: (context, state) {
        final full = state.profile?.fullName.trim() ?? '';
        return FaceVerifyName(name: full.isNotEmpty ? full : l10n.appName);
      },
    );
  }
}
