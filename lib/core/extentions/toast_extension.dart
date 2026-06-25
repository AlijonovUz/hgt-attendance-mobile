import 'package:flutter/material.dart';

import '../widgets/app_toast.dart';

/// `context.showSuccessToast('...')` kabi qisqa chaqiriqlar uchun.
extension ToastContextExtension on BuildContext {
  void showToast(
    String message, {
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) =>
      AppToast.show(this, message: message, type: type, duration: duration);

  void showSuccessToast(String message) =>
      showToast(message, type: AppToastType.success);

  void showErrorToast(String message) =>
      showToast(message, type: AppToastType.error);

  void showWarningToast(String message) =>
      showToast(message, type: AppToastType.warning);

  void showInfoToast(String message) =>
      showToast(message, type: AppToastType.info);
}
