// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Давомат';

  @override
  String get loginTitle => 'Вход в систему';

  @override
  String get loginSubtitle => 'Войдите в аккаунт, чтобы отметить посещаемость.';

  @override
  String get loginLoginLabel => 'Вход';

  @override
  String get loginFullNameHint => 'Ф.И.О.';

  @override
  String get loginPasswordLabel => 'Пароль';

  @override
  String get loginButton => 'Войти';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get langUzbekLatin => 'Uzbek';

  @override
  String get langUzbekCyrillic => 'Узбек';

  @override
  String get langRussian => 'Русский';

  @override
  String get loginInvalidCredentials => 'Неверный логин или пароль.';

  @override
  String loginAttemptsRemaining(int count) {
    return 'Осталось попыток: $count.';
  }

  @override
  String get loginBlockedTitle => 'Аккаунт временно заблокирован';

  @override
  String loginBlockedBody(int attempts, int minutes) {
    return 'Обнаружено $attempts неверных попыток. В целях безопасности аккаунт заблокирован на $minutes минут.';
  }

  @override
  String loginBlockedRetryIn(String time) {
    return 'Повторить через: $time';
  }

  @override
  String get loginBlockedRetryLabel => 'Повторить через:';

  @override
  String get faceHintDefault => 'Поместите лицо в круг';

  @override
  String get faceHintScanning => 'Проверка лица…';

  @override
  String get faceHintSuccess => 'Подтверждено';

  @override
  String get faceHintNoFace => 'Лицо не обнаружено. Смотрите в круг.';

  @override
  String get faceVerifyFailed => 'Не удалось подтвердить. Попробуйте ещё раз.';

  @override
  String get faceRetry => 'Повторить';

  @override
  String get facePermissionTitle => 'Нужен доступ к камере';

  @override
  String get facePermissionBody =>
      'Разрешите доступ к камере для подтверждения по лицу.';

  @override
  String get facePermissionOpenSettings => 'Открыть настройки';

  @override
  String get faceCameraError => 'Не удалось запустить камеру.';

  @override
  String get homeLogout => 'Выйти';

  @override
  String get profilePhotoPromptTitle =>
      'Пожалуйста, установите личное фото профиля, чтобы пройти сканирование!';

  @override
  String get profilePhotoUploadLabel => 'Загрузить фото';

  @override
  String get profilePhotoUploadButton => 'Загрузить';

  @override
  String get profileUsernameFallback => 'Username';

  @override
  String get profileUploadFailed =>
      'Не удалось загрузить фото. Попробуйте ещё раз.';

  @override
  String get profilePickFailed => 'Не удалось выбрать фото.';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonError => 'Что-то пошло не так. Повторите попытку позже.';

  @override
  String get networkError =>
      'Нет подключения к интернету. Проверьте соединение.';
}
