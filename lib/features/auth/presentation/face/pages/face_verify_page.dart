import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../app/bloc/session_bloc.dart';
import '../../../../../injection_container.dart';
import '../../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../../profile/presentation/widgets/profile_photo_prompt_sheet.dart';
import '../bloc/face_flow_mode.dart';
import '../bloc/face_verify_bloc.dart';
import '../widgets/face_verify_view.dart';

/// Login’dan keyingi yuz tasdig‘i ekrani (keyingi login’larda guard shu yerga
/// yo‘naltiradi). Universal [FaceVerifyView]ni [LoginFaceMode]da ishlatadi;
/// 2xx’da `SessionFaceVerified` yuboradi (tokenlar shunda saqlanadi).
class FaceVerifyPage extends StatelessWidget {
  const FaceVerifyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FaceVerifyBloc>(create: (_) => getIt<FaceVerifyBloc>()),
        BlocProvider<ProfileBloc>(create: (_) => getIt<ProfileBloc>()),
      ],
      child: const _FaceVerifyGate(),
    );
  }
}

class _FaceVerifyGate extends StatefulWidget {
  const _FaceVerifyGate();

  @override
  State<_FaceVerifyGate> createState() => _FaceVerifyGateState();
}

class _FaceVerifyGateState extends State<_FaceVerifyGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _begin());
  }

  /// Login javobida rasm bo‘lsa to‘g‘ridan-to‘g‘ri skan; bo‘lmasa avval majburiy
  /// rasm yuklash modali → PATCH `face_image` (RAM token) → keyin skan.
  Future<void> _begin() async {
    if (!mounted) return;
    final session = context.read<SessionBloc>();
    final token = session.pendingAccessToken ?? '';
    final fullName = session.pendingFullName ?? '';
    final hasFace = (session.pendingFaceImage ?? '').trim().isNotEmpty;

    if (!hasFace) {
      final profileBloc = context.read<ProfileBloc>()
        ..add(ProfileUploadAuthProvided(token));
      await showProfilePhotoPrompt(context, profileBloc, dismissible: false);
      if (!mounted) return;
    }

    context.read<FaceVerifyBloc>().add(
          FaceStarted(LoginFaceMode(accessToken: token, fullName: fullName)),
        );
  }

  @override
  Widget build(BuildContext context) {
    return FaceVerifyView(
      onSuccess: (context) =>
          context.read<SessionBloc>().add(const SessionFaceVerified()),
    );
  }
}
