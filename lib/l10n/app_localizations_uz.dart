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
  String get navHome => 'Asosiy';

  @override
  String get navHistory => 'Davomat tarixi';

  @override
  String get navProfile => 'Shaxsiy';

  @override
  String get homeWorkEndsIn => 'ish tugashiga qoldi';

  @override
  String get homeWorkedToday => 'bugungi ish vaqti';

  @override
  String get homeUntilStart => 'ish boshlanishiga qoldi';

  @override
  String get homeUntilLunch => 'tushlikka qoldi';

  @override
  String get homeUntilLunchEnd => 'tushlik tugashiga qoldi';

  @override
  String get homeTimeToArrive => 'Ishga kelish vaqti';

  @override
  String get homeTimeToLunchOut => 'Tushlikka chiqish vaqti';

  @override
  String get homeTimeToLunchIn => 'Tushlikdan qaytish vaqti';

  @override
  String get homeTimeToLeave => 'Ishdan ketish vaqti';

  @override
  String get homeSwipeArrive => 'Ishga keldim';

  @override
  String get homeSwipeHint => 'Belgilash uchun tugmani o‘ngga suring';

  @override
  String get homeAllDone => 'Bugungi davomat belgilandi';

  @override
  String get attendanceLocationError =>
      'Joylashuv aniqlanmadi. GPS va ruxsatni tekshiring.';

  @override
  String get homeTodaySchedule => 'Bugungi tartib';

  @override
  String get homeScheduleArrive => 'Ishga keldim';

  @override
  String get homeScheduleLunchOut => 'Tushlikka chiqdim';

  @override
  String get homeScheduleLunchIn => 'Tushlikdan qaytdim';

  @override
  String get homeScheduleLeave => 'Ishdan ketdim';

  @override
  String get homeKpi => 'Oylik KPI';

  @override
  String get homeMonthlyAttendance => 'Oylik davomat';

  @override
  String get profileFieldName => 'Ism sharif';

  @override
  String get profileFieldRole => 'Lavozim';

  @override
  String get profileFieldDepartment => 'Bo‘lim';

  @override
  String get profileFieldPhone => 'Telefon';

  @override
  String get historyEmpty => 'Hozircha davomat yozuvlari yo‘q';

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

  @override
  String get onbWelcomeTitle => 'Xush kelibsiz!';

  @override
  String get onbWelcomeSubtitle =>
      'Bu ilova orqali ishga kelish va ketishingizni qayd etasiz. Birinchi kirishda bir martalik sozlash kerak — bu 2 daqiqa vaqt oladi.';

  @override
  String get onbRoleEmployee => 'Xodim';

  @override
  String get onbContinue => 'Davom etish';

  @override
  String get onbPermissionsTitle => 'Ruxsatlar';

  @override
  String get onbPermissionsSubtitle =>
      'Ilova ishlashi uchun ikkita ruxsat zarur.';

  @override
  String get onbPermLocationTitle => 'Joylashuv (GPS)';

  @override
  String get onbPermLocationDesc => 'Ish hududida ekaningizni tekshirish uchun';

  @override
  String get onbPermCameraTitle => 'Kamera';

  @override
  String get onbPermCameraDesc => 'Face ID orqali shaxsni tasdiqlash uchun';

  @override
  String get onbGrant => 'Ruxsat berish';

  @override
  String get onbPasswordTitle => 'Yangi parol yarating';

  @override
  String get onbPasswordSubtitle =>
      'Kadrlar bo‘limi bergan vaqtinchalik parol o‘rniga o‘z parolingizni o‘rnating.';

  @override
  String get onbPasswordOldLabel => 'Eski parol';

  @override
  String get onbPasswordLabel => 'Yangi parol';

  @override
  String get onbPasswordConfirmLabel => 'Yangi parolni tasdiqlang';

  @override
  String get onbPasswordMismatch => 'Parollar mos kelmadi';

  @override
  String get onbRuleMinLength => 'Kamida 8 belgi';

  @override
  String get onbRuleUpper => 'Katta harf (A–Z)';

  @override
  String get onbRuleLower => 'Kichik harf (a–z)';

  @override
  String get onbRuleDigit => 'Raqam (0–9)';

  @override
  String get onbRuleSpecial => 'Maxsus belgi (!@#\$%...)';

  @override
  String get onbImageTitle => 'Shaxsiy rasmini o‘rnating';

  @override
  String get onbImageSubtitle =>
      'Bu rasm sizning asosiy suratingiz bo‘ladi. Har safar kirishda yuzingiz shu rasm bilan tekshiriladi.';

  @override
  String get onbImageUpload => 'Rasm yuklash';

  @override
  String get onbImageHint => 'Yuzingizni to‘liq ko‘rinsin';

  @override
  String get onbFaceTitle => 'Yuzni tekshirish';

  @override
  String get onbFaceSubtitle =>
      'Yuzingiz profil rasmi bilan solishtiriladi — mos kelsa, dasturga kiritilasiz.';

  @override
  String get onbFaceStart => 'Skanerlashni boshlash';

  @override
  String get onbDoneTitle => 'Hammasi tayyor!';

  @override
  String get onbDoneSubtitle =>
      'Endi davomatingizni qayd etishingiz mumkin. Har kuni ishga kelganda «Ishga keldim» tugmasini suring.';

  @override
  String get onbDoneStart => 'Ishni boshlash';
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
  String get navHome => 'Асосий';

  @override
  String get navHistory => 'Давомат тарихи';

  @override
  String get navProfile => 'Шахсий';

  @override
  String get homeWorkEndsIn => 'иш тугашига қолди';

  @override
  String get homeWorkedToday => 'бугунги иш вақти';

  @override
  String get homeUntilStart => 'иш бошланишига қолди';

  @override
  String get homeUntilLunch => 'тушликка қолди';

  @override
  String get homeUntilLunchEnd => 'тушлик тугашига қолди';

  @override
  String get homeTimeToArrive => 'Ишга келиш вақти';

  @override
  String get homeTimeToLunchOut => 'Тушликка чиқиш вақти';

  @override
  String get homeTimeToLunchIn => 'Тушликдан қайтиш вақти';

  @override
  String get homeTimeToLeave => 'Ишдан кетиш вақти';

  @override
  String get homeSwipeArrive => 'Ишга келдим';

  @override
  String get homeSwipeHint => 'Белгилаш учун тугмани ўнгга суринг';

  @override
  String get homeAllDone => 'Бугунги давомат белгиланди';

  @override
  String get attendanceLocationError =>
      'Жойлашув аниқланмади. GPS ва рухсатни текширинг.';

  @override
  String get homeTodaySchedule => 'Бугунги тартиб';

  @override
  String get homeScheduleArrive => 'Ишга келдим';

  @override
  String get homeScheduleLunchOut => 'Тушликка чиқдим';

  @override
  String get homeScheduleLunchIn => 'Тушликдан қайтдим';

  @override
  String get homeScheduleLeave => 'Ишдан кетдим';

  @override
  String get homeKpi => 'Ойлик KPI';

  @override
  String get homeMonthlyAttendance => 'Ойлик давомат';

  @override
  String get profileFieldName => 'Исм шариф';

  @override
  String get profileFieldRole => 'Лавозим';

  @override
  String get profileFieldDepartment => 'Бўлим';

  @override
  String get profileFieldPhone => 'Телефон';

  @override
  String get historyEmpty => 'Ҳозирча давомат ёзувлари йўқ';

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

  @override
  String get onbWelcomeTitle => 'Хуш келибсиз!';

  @override
  String get onbWelcomeSubtitle =>
      'Бу илова орқали ишга келиш ва кетишингизни қайд этасиз. Биринчи киришда бир марталик созлаш керак — бу 2 дақиқа вақт олади.';

  @override
  String get onbRoleEmployee => 'Ходим';

  @override
  String get onbContinue => 'Давом этиш';

  @override
  String get onbPermissionsTitle => 'Рухсатлар';

  @override
  String get onbPermissionsSubtitle => 'Илова ишлаши учун иккита рухсат зарур.';

  @override
  String get onbPermLocationTitle => 'Жойлашув (GPS)';

  @override
  String get onbPermLocationDesc => 'Иш ҳудудида эканингизни текшириш учун';

  @override
  String get onbPermCameraTitle => 'Камера';

  @override
  String get onbPermCameraDesc => 'Face ID орқали шахсни тасдиқлаш учун';

  @override
  String get onbGrant => 'Рухсат бериш';

  @override
  String get onbPasswordTitle => 'Янги парол яратинг';

  @override
  String get onbPasswordSubtitle =>
      'Кадрлар бўлими берган вақтинчалик парол ўрнига ўз паролингизни ўрнатинг.';

  @override
  String get onbPasswordOldLabel => 'Эски парол';

  @override
  String get onbPasswordLabel => 'Янги парол';

  @override
  String get onbPasswordConfirmLabel => 'Янги паролни тасдиқланг';

  @override
  String get onbPasswordMismatch => 'Пароллар мос келмади';

  @override
  String get onbRuleMinLength => 'Камида 8 белги';

  @override
  String get onbRuleUpper => 'Катта ҳарф (A–Z)';

  @override
  String get onbRuleLower => 'Кичик ҳарф (a–z)';

  @override
  String get onbRuleDigit => 'Рақам (0–9)';

  @override
  String get onbRuleSpecial => 'Махсус белги (!@#\$%...)';

  @override
  String get onbImageTitle => 'Шахсий расмини ўрнатинг';

  @override
  String get onbImageSubtitle =>
      'Бу расм сизнинг асосий суратингиз бўлади. Ҳар сафар киришда юзингиз шу расм билан текширилади.';

  @override
  String get onbImageUpload => 'Расм юклаш';

  @override
  String get onbImageHint => 'Юзингизни тўлиқ кўринсин';

  @override
  String get onbFaceTitle => 'Юзни текшириш';

  @override
  String get onbFaceSubtitle =>
      'Юзингиз профил расми билан солиштирилади — мос келса, дастурга киритиласиз.';

  @override
  String get onbFaceStart => 'Сканерлашни бошлаш';

  @override
  String get onbDoneTitle => 'Ҳаммаси тайёр!';

  @override
  String get onbDoneSubtitle =>
      'Энди давоматингизни қайд этишингиз мумкин. Ҳар куни ишга келганда «Ишга келдим» тугмасини суринг.';

  @override
  String get onbDoneStart => 'Ишни бошлаш';
}
