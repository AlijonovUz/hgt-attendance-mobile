// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Посещаемость';

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
  String get navHome => 'Главная';

  @override
  String get navHistory => 'История';

  @override
  String get navProfile => 'Профиль';

  @override
  String get homeWorkEndsIn => 'до конца работы';

  @override
  String get homeWorkedToday => 'отработано сегодня';

  @override
  String get homeUntilStart => 'до начала работы';

  @override
  String get homeUntilLunch => 'до обеда';

  @override
  String get homeUntilLunchEnd => 'до конца обеда';

  @override
  String get homeTimeToArrive => 'Время прийти на работу';

  @override
  String get homeTimeToLunchOut => 'Время уйти на обед';

  @override
  String get homeTimeToLunchIn => 'Время вернуться с обеда';

  @override
  String get homeTimeToLeave => 'Время уйти с работы';

  @override
  String get homeNotStarted => 'Начать работу';

  @override
  String get homeWorkDayDone => 'Рабочий день завершён';

  @override
  String get homeSwipeArrive => 'Я пришёл';

  @override
  String get homeSwipeHint => 'Проведите кнопку вправо, чтобы отметить';

  @override
  String get homeAllDone => 'Посещаемость на сегодня отмечена';

  @override
  String get attendanceLocationError =>
      'Не удалось определить местоположение. Проверьте GPS и разрешение.';

  @override
  String get homeTodaySchedule => 'Распорядок на сегодня';

  @override
  String get homeScheduleArrive => 'Пришёл на работу';

  @override
  String get homeScheduleLunchOut => 'Ушёл на обед';

  @override
  String get homeScheduleLunchIn => 'Вернулся с обеда';

  @override
  String get homeScheduleLeave => 'Ушёл с работы';

  @override
  String get homeKpi => 'Месячный KPI';

  @override
  String get homeMonthlyAttendance => 'Месячная посещаемость';

  @override
  String get profileFieldName => 'Ф.И.О.';

  @override
  String get profileFieldRole => 'Должность';

  @override
  String get profileFieldDepartment => 'Отдел';

  @override
  String get profileFieldBranch => 'Филиал';

  @override
  String get profileFieldRegion => 'Область';

  @override
  String get profileFieldDistrict => 'Район';

  @override
  String get profileFieldPhone => 'Телефон';

  @override
  String get profileChangePassword => 'Изменить пароль';

  @override
  String get logoutTitle => 'Выйти из профиля?';

  @override
  String get logoutBody =>
      'Вы выйдете из профиля, и для повторного входа потребуется снова авторизоваться в системе';

  @override
  String get logoutBack => 'Назад';

  @override
  String get cpwConfirmLabel => 'Повторите новый пароль';

  @override
  String get cpwSave => 'Сохранить';

  @override
  String get cpwSuccess => 'Пароль успешно изменён';

  @override
  String get historyEmpty => 'Пока нет записей о посещаемости';

  @override
  String get historyTabDaily => 'День';

  @override
  String get historyTabWeekly => 'Неделя';

  @override
  String get historyTabMonthly => 'Месяц';

  @override
  String get historyStatPresent => 'Выходов';

  @override
  String get historyStatLate => 'Опозданий';

  @override
  String get historyStatAvgArrival => 'Среднее прибытие';

  @override
  String get historyStatWorked => 'Всего отработано';

  @override
  String get historyUnitDays => 'дн.';

  @override
  String get historyUnitHours => 'ч';

  @override
  String get historyUnitMinutes => 'мин';

  @override
  String get historyToday => 'Сегодня';

  @override
  String get historyYesterday => 'Вчера';

  @override
  String get historyEventArrived => 'Пришёл на работу';

  @override
  String get historyEventLunchOut => 'Ушёл на обед';

  @override
  String get historyEventLunchIn => 'Вернулся с обеда';

  @override
  String get historyEventLeft => 'Ушёл с работы';

  @override
  String get historyError => 'Не удалось загрузить данные. Попробуйте ещё раз.';

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get notificationsEmpty => 'Пока нет уведомлений';

  @override
  String get notificationsError =>
      'Не удалось загрузить уведомления. Попробуйте ещё раз.';

  @override
  String get notificationsMarkAllRead => 'Отметить все как прочитанные';

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

  @override
  String get onbWelcomeTitle => 'Добро пожаловать!';

  @override
  String get onbWelcomeSubtitle =>
      'Через это приложение вы будете отмечать приход и уход с работы. При первом входе нужна разовая настройка — она займёт 2 минуты.';

  @override
  String get onbRoleEmployee => 'Сотрудник';

  @override
  String get onbContinue => 'Продолжить';

  @override
  String get onbPermissionsTitle => 'Разрешения';

  @override
  String get onbPermissionsSubtitle =>
      'Для работы приложения нужны два разрешения.';

  @override
  String get onbPermLocationTitle => 'Местоположение (GPS)';

  @override
  String get onbPermLocationDesc =>
      'Чтобы проверить, что вы находитесь на рабочей территории';

  @override
  String get onbPermCameraTitle => 'Камера';

  @override
  String get onbPermCameraDesc => 'Для подтверждения личности через Face ID';

  @override
  String get onbGrant => 'Разрешить';

  @override
  String get onbPasswordTitle => 'Создайте новый пароль';

  @override
  String get onbPasswordSubtitle =>
      'Установите свой пароль вместо временного, выданного отделом кадров.';

  @override
  String get onbPasswordOldLabel => 'Старый пароль';

  @override
  String get onbPasswordLabel => 'Новый пароль';

  @override
  String get onbPasswordConfirmLabel => 'Подтвердите новый пароль';

  @override
  String get onbPasswordMismatch => 'Пароли не совпадают';

  @override
  String get onbRuleMinLength => 'Не менее 8 символов';

  @override
  String get onbRuleUpper => 'Заглавная буква (A–Z)';

  @override
  String get onbRuleLower => 'Строчная буква (a–z)';

  @override
  String get onbRuleDigit => 'Цифра (0–9)';

  @override
  String get onbRuleSpecial => 'Специальный символ (!@#\$%...)';

  @override
  String get onbImageTitle => 'Установите личное фото';

  @override
  String get onbImageSubtitle =>
      'Это фото станет вашим основным снимком. При каждом входе ваше лицо будет сверяться с этим фото.';

  @override
  String get onbImageUpload => 'Загрузить фото';

  @override
  String get onbImageHint => 'Лицо должно быть полностью видно';

  @override
  String get onbFaceTitle => 'Проверка лица';

  @override
  String get onbFaceSubtitle =>
      'Ваше лицо сверяется с фото профиля — при совпадении вы войдёте в приложение.';

  @override
  String get onbFaceStart => 'Начать сканирование';

  @override
  String get onbDoneTitle => 'Всё готово!';

  @override
  String get onbDoneSubtitle =>
      'Теперь вы можете отмечать посещаемость. Каждый день при приходе на работу нажимайте кнопку «Я пришёл».';

  @override
  String get onbDoneStart => 'Начать работу';
}
