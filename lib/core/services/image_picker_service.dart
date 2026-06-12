import 'package:image_picker/image_picker.dart';

/// Qurilma xotirasi/kamerasidan rasm tanlash uchun yupqa o‘rama.
///
/// Bloclar `image_picker`ga to‘g‘ridan-to‘g‘ri bog‘lanmaydi — shu servis orqali
/// (DI’da ro‘yxatdan o‘tadi, testda mock qilinadi). Bekor qilinsa `null` qaytadi.
class ImagePickerService {
  ImagePickerService([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Galereyadan (qurilma xotirasidan) rasm tanlaydi → fayl yo‘li yoki `null`.
  Future<String?> pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      imageQuality: 85,
    );
    return file?.path;
  }

  /// Kameradan suratga oladi → fayl yo‘li yoki `null`.
  Future<String?> pickFromCamera() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1280,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.front,
    );
    return file?.path;
  }
}
