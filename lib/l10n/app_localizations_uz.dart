// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appName => 'Davomat';

  @override
  String get loginTitle => 'Tizimga kirish';

  @override
  String get loginSubtitle => 'Davomatni qayd etish uchun hisobingizga kiring.';

  @override
  String get loginLoginLabel => 'Kirish';

  @override
  String get loginFullNameHint => 'Ism sharif';

  @override
  String get loginPasswordLabel => 'Parol';

  @override
  String get loginButton => 'Kirish';

  @override
  String get themeLight => 'Yorug‘';

  @override
  String get themeDark => 'Qorong‘i';

  @override
  String get langUzbekLatin => 'Uzbek';

  @override
  String get langUzbekCyrillic => 'Узбек';

  @override
  String get langRussian => 'Русский';

  @override
  String get loginInvalidCredentials => 'Login yoki parol noto‘g‘ri.';

  @override
  String loginAttemptsRemaining(int count) {
    return 'Yana $count marta urinish mumkin.';
  }

  @override
  String get loginBlockedTitle => 'Hisob vaqtincha bloklandi';

  @override
  String loginBlockedBody(int attempts, int minutes) {
    return '$attempts marta noto‘g‘ri urinish aniqlandi. Xavfsizlik uchun hisobingiz $minutes daqiqaga bloklandi.';
  }

  @override
  String loginBlockedRetryIn(String time) {
    return 'Qayta urinish: $time';
  }

  @override
  String get loginBlockedRetryLabel => 'Qayta urinish:';

  @override
  String get faceHintDefault => 'Yuzingizni doira ichida joylashtiring';

  @override
  String get faceHintScanning => 'Yuz tekshirilmoqda…';

  @override
  String get faceHintSuccess => 'Tasdiqlandi';

  @override
  String get faceHintNoFace => 'Yuz aniqlanmadi. Doira ichiga qarang.';

  @override
  String get faceVerifyFailed =>
      'Tasdiqlash amalga oshmadi. Qayta urinib ko‘ring.';

  @override
  String get faceRetry => 'Qayta urinish';

  @override
  String get facePermissionTitle => 'Kameraga ruxsat kerak';

  @override
  String get facePermissionBody =>
      'Yuz orqali tasdiqlash uchun kameraga ruxsat bering.';

  @override
  String get facePermissionOpenSettings => 'Sozlamalarni ochish';

  @override
  String get faceCameraError => 'Kamera ishga tushmadi.';

  @override
  String get homeLogout => 'Chiqish';

  @override
  String get profilePhotoPromptTitle =>
      'Iltimos, skanerlashdan o‘tish uchun profilingiz uchun shaxsiy rasmingizni o‘rnating!';

  @override
  String get profilePhotoUploadLabel => 'Rasm yuklash';

  @override
  String get profilePhotoUploadButton => 'Yuklash';

  @override
  String get profileUsernameFallback => 'Username';

  @override
  String get profileUploadFailed => 'Rasm yuklanmadi. Qayta urinib ko‘ring.';

  @override
  String get profilePickFailed => 'Rasmni tanlab bo‘lmadi.';

  @override
  String get commonCancel => 'Bekor qilish';

  @override
  String get commonError =>
      'Nimadir xato ketdi. Birozdan so‘ng qayta urinib ko‘ring.';

  @override
  String get networkError => 'Internet aloqasi yo‘q. Ulanishni tekshiring.';
}

/// The translations for Uzbek, using the Cyrillic script (`uz_Cyrl`).
class AppLocalizationsUzCyrl extends AppLocalizationsUz {
  AppLocalizationsUzCyrl() : super('uz_Cyrl');

  @override
  String get appName => 'Давомат';

  @override
  String get loginTitle => 'Тизимга кириш';

  @override
  String get loginSubtitle => 'Давоматни қайд этиш учун ҳисобингизга киринг.';

  @override
  String get loginLoginLabel => 'Кириш';

  @override
  String get loginFullNameHint => 'Исм шариф';

  @override
  String get loginPasswordLabel => 'Парол';

  @override
  String get loginButton => 'Кириш';

  @override
  String get themeLight => 'Ёруғ';

  @override
  String get themeDark => 'Қоронғи';

  @override
  String get langUzbekLatin => 'Uzbek';

  @override
  String get langUzbekCyrillic => 'Узбек';

  @override
  String get langRussian => 'Русский';

  @override
  String get loginInvalidCredentials => 'Логин ёки парол нотўғри.';

  @override
  String loginAttemptsRemaining(int count) {
    return 'Яна $count марта уриниш мумкин.';
  }

  @override
  String get loginBlockedTitle => 'Ҳисоб вақтинча блокланди';

  @override
  String loginBlockedBody(int attempts, int minutes) {
    return '$attempts марта нотўғри уриниш аниқланди. Хавфсизлик учун ҳисобингиз $minutes дақиқага блокланди.';
  }

  @override
  String loginBlockedRetryIn(String time) {
    return 'Қайта уриниш: $time';
  }

  @override
  String get loginBlockedRetryLabel => 'Қайта уриниш:';

  @override
  String get faceHintDefault => 'Юзингизни доира ичида жойлаштиринг';

  @override
  String get faceHintScanning => 'Юз текширилмоқда…';

  @override
  String get faceHintSuccess => 'Тасдиқланди';

  @override
  String get faceHintNoFace => 'Юз аниқланмади. Доира ичига қаранг.';

  @override
  String get faceVerifyFailed =>
      'Тасдиқлаш амалга ошмади. Қайта уриниб кўринг.';

  @override
  String get faceRetry => 'Қайта уриниш';

  @override
  String get facePermissionTitle => 'Камерага рухсат керак';

  @override
  String get facePermissionBody =>
      'Юз орқали тасдиқлаш учун камерага рухсат беринг.';

  @override
  String get facePermissionOpenSettings => 'Созламаларни очиш';

  @override
  String get faceCameraError => 'Камера ишга тушмади.';

  @override
  String get homeLogout => 'Чиқиш';

  @override
  String get profilePhotoPromptTitle =>
      'Илтимос, сканерлашдан ўтиш учун профилингиз учун шахсий расмингизни ўрнатинг!';

  @override
  String get profilePhotoUploadLabel => 'Расм юклаш';

  @override
  String get profilePhotoUploadButton => 'Юклаш';

  @override
  String get profileUsernameFallback => 'Username';

  @override
  String get profileUploadFailed => 'Расм юкланмади. Қайта уриниб кўринг.';

  @override
  String get profilePickFailed => 'Расмни танлаб бўлмади.';

  @override
  String get commonCancel => 'Бекор қилиш';

  @override
  String get commonError =>
      'Нимадир хато кетди. Бироздан сўнг қайта уриниб кўринг.';

  @override
  String get networkError => 'Интернет алоқаси йўқ. Уланишни текширинг.';
}
