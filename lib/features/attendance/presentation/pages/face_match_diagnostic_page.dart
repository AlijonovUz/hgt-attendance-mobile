import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/services/face_embedder_service.dart';
import '../../../../core/services/face_match_service.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../injection_container.dart';

/// **Debug diagnostika** — kamera/offline oqimga bog‘liq bo‘lmagan holda ikkita
/// rasmni (reference + selfie) galereyadan tanlab MobileFaceNet bilan
/// solishtiradi va butun quvur logini **ekranda** ko‘rsatadi (model yuklash,
/// tensor shakli, yuz soni, cosine `sim`, xato). `simThreshold`ni kalibrlash va
/// «nega mismatch?» savolini qurilmada tez tekshirish uchun.
///
/// Bu sahifa o‘zining `FaceMatchService`ini yaratadi (logni ekranga yo‘naltirgan
/// `LoggerService` bilan), DI singleton’iga tegmaydi.
class FaceMatchDiagnosticPage extends StatefulWidget {
  const FaceMatchDiagnosticPage({super.key});

  @override
  State<FaceMatchDiagnosticPage> createState() =>
      _FaceMatchDiagnosticPageState();
}

class _FaceMatchDiagnosticPageState extends State<FaceMatchDiagnosticPage> {
  final ImagePickerService _picker = getIt<ImagePickerService>();
  final List<String> _logs = <String>[];
  final ScrollController _logScroll = ScrollController();

  late final FaceMatchService _service = FaceMatchService(
    FaceEmbedderService(LoggerService(logSink: _capture)),
    LoggerService(logSink: _capture),
  );

  String? _referencePath;
  String? _selfiePath;
  bool _running = false;
  FaceMatchResult? _result;

  void _capture(String message) {
    if (!mounted) return;
    setState(() => _logs.add(message));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logScroll.hasClients) {
        _logScroll.jumpTo(_logScroll.position.maxScrollExtent);
      }
    });
  }

  Future<void> _pickReference() async {
    final path = await _picker.pickFromGallery();
    if (path != null) setState(() => _referencePath = path);
  }

  Future<void> _pickSelfieGallery() async {
    final path = await _picker.pickFromGallery();
    if (path != null) setState(() => _selfiePath = path);
  }

  Future<void> _pickSelfieCamera() async {
    final path = await _picker.pickFromCamera();
    if (path != null) setState(() => _selfiePath = path);
  }

  Future<void> _compare() async {
    final ref = _referencePath;
    final selfie = _selfiePath;
    if (ref == null || selfie == null || _running) return;
    setState(() {
      _running = true;
      _result = null;
      _logs.clear();
    });
    final result = await _service.diagnose(referencePath: ref, selfiePath: selfie);
    if (!mounted) return;
    setState(() {
      _result = result;
      _running = false;
    });
  }

  @override
  void dispose() {
    _service.dispose();
    _logScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.backgroundBase,
      appBar: AppBar(
        backgroundColor: colors.backgroundBase,
        title: 'Yuz moslik diagnostika'.s(18.sp).w(600).c(colors.textStrong),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _PickTile(
                      label: 'Reference (saqlangan)',
                      path: _referencePath,
                      onTap: _pickReference,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _PickTile(
                      label: 'Selfie (kamera/galereya)',
                      path: _selfiePath,
                      onTap: _pickSelfieGallery,
                      onLongPress: _pickSelfieCamera,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              'Selfie tile: bosish → galereya, bosib turish → kamera'
                  .s(11.sp)
                  .c(colors.textSoft),
              SizedBox(height: 12.h),
              SizedBox(
                height: 48.h,
                child: ElevatedButton(
                  onPressed: (_referencePath != null &&
                          _selfiePath != null &&
                          !_running)
                      ? _compare
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.accentStrong,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: _running
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.textWhite,
                          ),
                        )
                      : 'Solishtirish'.s(15.sp).w(600).c(colors.textWhite),
                ),
              ),
              if (_result != null) ...[
                SizedBox(height: 12.h),
                _ResultCard(result: _result!),
              ],
              SizedBox(height: 12.h),
              'Loglar'.s(13.sp).w(600).c(colors.textSub),
              SizedBox(height: 6.h),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.backgroundElevation1,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: colors.strokeSoft),
                  ),
                  child: _logs.isEmpty
                      ? Center(
                          child: 'Hali log yo‘q — «Solishtirish»ni bosing'
                              .s(12.sp)
                              .c(colors.textSoft),
                        )
                      : ListView.builder(
                          controller: _logScroll,
                          padding: EdgeInsets.all(10.r),
                          itemCount: _logs.length,
                          itemBuilder: (_, i) => Padding(
                            padding: EdgeInsets.only(bottom: 4.h),
                            child: Text(
                              _logs[i],
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11.sp,
                                color: colors.textStrong,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickTile extends StatelessWidget {
  const _PickTile({
    required this.label,
    required this.path,
    required this.onTap,
    this.onLongPress,
  });

  final String label;
  final String? path;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.backgroundElevation1,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colors.strokeSoft),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              child: SizedBox(
                height: 120.h,
                width: double.infinity,
                child: path != null
                    ? Image.file(File(path!), fit: BoxFit.cover)
                    : Center(
                        child: Icon(
                          Icons.add_a_photo_outlined,
                          color: colors.iconSoft,
                          size: 28.r,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.r),
              child: label.s(11.sp).w(500).c(colors.textSub).a(TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final FaceMatchResult result;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final ok = result.match;
    final accent = ok ? colors.successStrong : colors.errorStrong;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: accent),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  ok ? Icons.check_circle : Icons.cancel,
                  color: accent,
                  size: 20.r,
                ),
                SizedBox(width: 8.w),
                (ok ? 'MOS — bir xil odam' : 'MOS EMAS')
                    .s(15.sp)
                    .w(700)
                    .c(accent),
              ],
            ),
            SizedBox(height: 8.h),
            _kv(colors, 'similarity (cosine)',
                result.similarity?.toStringAsFixed(4) ?? '—'),
            _kv(colors, 'chegara (simThreshold)',
                FaceMatchService.simThreshold.toString()),
            _kv(colors, 'distance (euclid)',
                result.distance?.toStringAsFixed(4) ?? '—'),
            _kv(colors, 'reference yuzlar', '${result.referenceFaces}'),
            _kv(colors, 'selfie yuzlar', '${result.selfieFaces}'),
            if (result.error != null)
              _kv(colors, 'xato', result.error!, error: true),
          ],
        ),
      ),
    );
  }

  Widget _kv(AppColors colors, String k, String v, {bool error = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150.w,
            child: k.s(12.sp).c(colors.textSub),
          ),
          Expanded(
            child: v
                .s(12.sp)
                .w(600)
                .c(error ? colors.errorStrong : colors.textStrong),
          ),
        ],
      ),
    );
  }
}
