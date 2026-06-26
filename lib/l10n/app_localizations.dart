import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('uz'),
    Locale('ru'),
    Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl'),
  ];

  /// No description provided for @appName.
  ///
  /// In uz, this message translates to:
  /// **'Davomat'**
  String get appName;

  /// No description provided for @loginTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tizimga kirish'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Davomatni qayd etish uchun hisobingizga kiring.'**
  String get loginSubtitle;

  /// No description provided for @loginLoginLabel.
  ///
  /// In uz, this message translates to:
  /// **'Kirish'**
  String get loginLoginLabel;

  /// No description provided for @loginFullNameHint.
  ///
  /// In uz, this message translates to:
  /// **'Ism sharif'**
  String get loginFullNameHint;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In uz, this message translates to:
  /// **'Parol'**
  String get loginPasswordLabel;

  /// No description provided for @loginButton.
  ///
  /// In uz, this message translates to:
  /// **'Kirish'**
  String get loginButton;

  /// No description provided for @themeLight.
  ///
  /// In uz, this message translates to:
  /// **'Yorug‘'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In uz, this message translates to:
  /// **'Qorong‘i'**
  String get themeDark;

  /// No description provided for @langUzbekLatin.
  ///
  /// In uz, this message translates to:
  /// **'Uzbek'**
  String get langUzbekLatin;

  /// No description provided for @langUzbekCyrillic.
  ///
  /// In uz, this message translates to:
  /// **'Узбек'**
  String get langUzbekCyrillic;

  /// No description provided for @langRussian.
  ///
  /// In uz, this message translates to:
  /// **'Русский'**
  String get langRussian;

  /// No description provided for @profileAppLanguage.
  ///
  /// In uz, this message translates to:
  /// **'Ilova tili'**
  String get profileAppLanguage;

  /// No description provided for @profileLanguageSheetTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ilova tilini tanlang'**
  String get profileLanguageSheetTitle;

  /// No description provided for @loginInvalidCredentials.
  ///
  /// In uz, this message translates to:
  /// **'Login yoki parol noto‘g‘ri.'**
  String get loginInvalidCredentials;

  /// No description provided for @loginAttemptsRemaining.
  ///
  /// In uz, this message translates to:
  /// **'Yana {count} marta urinish mumkin.'**
  String loginAttemptsRemaining(int count);

  /// No description provided for @loginBlockedTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hisob vaqtincha bloklandi'**
  String get loginBlockedTitle;

  /// No description provided for @loginBlockedBody.
  ///
  /// In uz, this message translates to:
  /// **'{attempts} marta noto‘g‘ri urinish aniqlandi. Xavfsizlik uchun hisobingiz {minutes} daqiqaga bloklandi.'**
  String loginBlockedBody(int attempts, int minutes);

  /// No description provided for @loginBlockedRetryIn.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinish: {time}'**
  String loginBlockedRetryIn(String time);

  /// No description provided for @loginBlockedRetryLabel.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinish:'**
  String get loginBlockedRetryLabel;

  /// No description provided for @faceVerifyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yuzni tasdiqlang'**
  String get faceVerifyTitle;

  /// No description provided for @faceVerifySubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Telefonni yuz balandligida ushlang va doira ichiga qarang. Tekshiruv avtomatik amalga oshadi.'**
  String get faceVerifySubtitle;

  /// No description provided for @faceHintGoodLight.
  ///
  /// In uz, this message translates to:
  /// **'Yorug‘ joyda turing'**
  String get faceHintGoodLight;

  /// No description provided for @faceHintFullFace.
  ///
  /// In uz, this message translates to:
  /// **'Yuzingizni to‘liq ko‘rsating'**
  String get faceHintFullFace;

  /// No description provided for @faceHintDefault.
  ///
  /// In uz, this message translates to:
  /// **'Yuzingizni doira ichida joylashtiring'**
  String get faceHintDefault;

  /// No description provided for @faceHintScanning.
  ///
  /// In uz, this message translates to:
  /// **'Yuz tekshirilmoqda…'**
  String get faceHintScanning;

  /// No description provided for @faceHintSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlandi'**
  String get faceHintSuccess;

  /// No description provided for @faceHintNoFace.
  ///
  /// In uz, this message translates to:
  /// **'Yuz aniqlanmadi. Doira ichiga qarang.'**
  String get faceHintNoFace;

  /// No description provided for @faceVerifyFailed.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash amalga oshmadi. Qayta urinib ko‘ring.'**
  String get faceVerifyFailed;

  /// No description provided for @faceRetry.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinish'**
  String get faceRetry;

  /// No description provided for @facePermissionTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kameraga ruxsat kerak'**
  String get facePermissionTitle;

  /// No description provided for @facePermissionBody.
  ///
  /// In uz, this message translates to:
  /// **'Yuz orqali tasdiqlash uchun kameraga ruxsat bering.'**
  String get facePermissionBody;

  /// No description provided for @facePermissionOpenSettings.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalarni ochish'**
  String get facePermissionOpenSettings;

  /// No description provided for @faceCameraError.
  ///
  /// In uz, this message translates to:
  /// **'Kamera ishga tushmadi.'**
  String get faceCameraError;

  /// No description provided for @homeLogout.
  ///
  /// In uz, this message translates to:
  /// **'Chiqish'**
  String get homeLogout;

  /// No description provided for @navHome.
  ///
  /// In uz, this message translates to:
  /// **'Asosiy'**
  String get navHome;

  /// No description provided for @navHistory.
  ///
  /// In uz, this message translates to:
  /// **'Davomat tarixi'**
  String get navHistory;

  /// No description provided for @navProfile.
  ///
  /// In uz, this message translates to:
  /// **'Shaxsiy'**
  String get navProfile;

  /// No description provided for @homeWorkEndsIn.
  ///
  /// In uz, this message translates to:
  /// **'ish tugashiga qoldi'**
  String get homeWorkEndsIn;

  /// No description provided for @homeWorkedToday.
  ///
  /// In uz, this message translates to:
  /// **'bugungi ish vaqti'**
  String get homeWorkedToday;

  /// No description provided for @homeUntilStart.
  ///
  /// In uz, this message translates to:
  /// **'ish boshlanishiga qoldi'**
  String get homeUntilStart;

  /// No description provided for @homeUntilLunch.
  ///
  /// In uz, this message translates to:
  /// **'tushlikka qoldi'**
  String get homeUntilLunch;

  /// No description provided for @homeUntilLunchEnd.
  ///
  /// In uz, this message translates to:
  /// **'tushlik tugashiga qoldi'**
  String get homeUntilLunchEnd;

  /// No description provided for @homeTimeToArrive.
  ///
  /// In uz, this message translates to:
  /// **'Ishga kelish vaqti'**
  String get homeTimeToArrive;

  /// No description provided for @homeTimeToLunchOut.
  ///
  /// In uz, this message translates to:
  /// **'Tushlikka chiqish vaqti'**
  String get homeTimeToLunchOut;

  /// No description provided for @homeTimeToLunchIn.
  ///
  /// In uz, this message translates to:
  /// **'Tushlikdan qaytish vaqti'**
  String get homeTimeToLunchIn;

  /// No description provided for @homeTimeToLeave.
  ///
  /// In uz, this message translates to:
  /// **'Ishdan ketish vaqti'**
  String get homeTimeToLeave;

  /// No description provided for @homeNotStarted.
  ///
  /// In uz, this message translates to:
  /// **'Ishni boshlash'**
  String get homeNotStarted;

  /// No description provided for @homeWorkDayDone.
  ///
  /// In uz, this message translates to:
  /// **'Ish kuni yakunlandi'**
  String get homeWorkDayDone;

  /// No description provided for @homeSwipeArrive.
  ///
  /// In uz, this message translates to:
  /// **'Ishga keldim'**
  String get homeSwipeArrive;

  /// No description provided for @homeSwipeHint.
  ///
  /// In uz, this message translates to:
  /// **'Belgilash uchun tugmani o‘ngga suring'**
  String get homeSwipeHint;

  /// No description provided for @homeAllDone.
  ///
  /// In uz, this message translates to:
  /// **'Bugungi davomat belgilandi'**
  String get homeAllDone;

  /// No description provided for @attendanceLocationError.
  ///
  /// In uz, this message translates to:
  /// **'Joylashuv aniqlanmadi. GPS va ruxsatni tekshiring.'**
  String get attendanceLocationError;

  /// No description provided for @locationServiceOffTitle.
  ///
  /// In uz, this message translates to:
  /// **'GPS o‘chiq'**
  String get locationServiceOffTitle;

  /// No description provided for @locationServiceOffBody.
  ///
  /// In uz, this message translates to:
  /// **'Davomatni belgilash uchun joylashuv (GPS) yoqilgan bo‘lishi kerak. Iltimos, GPS’ni yoqing.'**
  String get locationServiceOffBody;

  /// No description provided for @locationServiceOffEnable.
  ///
  /// In uz, this message translates to:
  /// **'Yoqish'**
  String get locationServiceOffEnable;

  /// No description provided for @homeTodaySchedule.
  ///
  /// In uz, this message translates to:
  /// **'Bugungi tartib'**
  String get homeTodaySchedule;

  /// No description provided for @homeScheduleArrive.
  ///
  /// In uz, this message translates to:
  /// **'Ishga keldim'**
  String get homeScheduleArrive;

  /// No description provided for @homeScheduleLunchOut.
  ///
  /// In uz, this message translates to:
  /// **'Tushlikka chiqdim'**
  String get homeScheduleLunchOut;

  /// No description provided for @homeScheduleLunchIn.
  ///
  /// In uz, this message translates to:
  /// **'Tushlikdan qaytdim'**
  String get homeScheduleLunchIn;

  /// No description provided for @homeScheduleLeave.
  ///
  /// In uz, this message translates to:
  /// **'Ishdan ketdim'**
  String get homeScheduleLeave;

  /// No description provided for @homeKpi.
  ///
  /// In uz, this message translates to:
  /// **'Oylik KPI'**
  String get homeKpi;

  /// No description provided for @homeMonthlyAttendance.
  ///
  /// In uz, this message translates to:
  /// **'Oylik davomat'**
  String get homeMonthlyAttendance;

  /// No description provided for @profileFieldName.
  ///
  /// In uz, this message translates to:
  /// **'Ism sharif'**
  String get profileFieldName;

  /// No description provided for @profileFieldRole.
  ///
  /// In uz, this message translates to:
  /// **'Lavozim'**
  String get profileFieldRole;

  /// No description provided for @profileFieldDepartment.
  ///
  /// In uz, this message translates to:
  /// **'Bo‘lim'**
  String get profileFieldDepartment;

  /// No description provided for @profileFieldBranch.
  ///
  /// In uz, this message translates to:
  /// **'Filial'**
  String get profileFieldBranch;

  /// No description provided for @profileFieldRegion.
  ///
  /// In uz, this message translates to:
  /// **'Viloyat'**
  String get profileFieldRegion;

  /// No description provided for @profileFieldDistrict.
  ///
  /// In uz, this message translates to:
  /// **'Tuman'**
  String get profileFieldDistrict;

  /// No description provided for @profileFieldPhone.
  ///
  /// In uz, this message translates to:
  /// **'Telefon'**
  String get profileFieldPhone;

  /// No description provided for @profileChangePassword.
  ///
  /// In uz, this message translates to:
  /// **'Parol o‘zgartirish'**
  String get profileChangePassword;

  /// No description provided for @logoutTitle.
  ///
  /// In uz, this message translates to:
  /// **'Profilingizdan chiqmoqchimisiz?'**
  String get logoutTitle;

  /// No description provided for @logoutBody.
  ///
  /// In uz, this message translates to:
  /// **'Profilingizdan chiqasiz va qayta kirish uchun tizimga yana login qilishingiz kerak bo‘ladi'**
  String get logoutBody;

  /// No description provided for @logoutBack.
  ///
  /// In uz, this message translates to:
  /// **'Orqaga'**
  String get logoutBack;

  /// No description provided for @cpwConfirmLabel.
  ///
  /// In uz, this message translates to:
  /// **'Yangi parolni takrorlash'**
  String get cpwConfirmLabel;

  /// No description provided for @cpwSave.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get cpwSave;

  /// No description provided for @cpwSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Parol muvaffaqiyatli o‘zgartirildi'**
  String get cpwSuccess;

  /// No description provided for @historyEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha davomat yozuvlari yo‘q'**
  String get historyEmpty;

  /// No description provided for @historyTabDaily.
  ///
  /// In uz, this message translates to:
  /// **'Kunlik'**
  String get historyTabDaily;

  /// No description provided for @historyTabWeekly.
  ///
  /// In uz, this message translates to:
  /// **'Haftalik'**
  String get historyTabWeekly;

  /// No description provided for @historyTabMonthly.
  ///
  /// In uz, this message translates to:
  /// **'Oylik'**
  String get historyTabMonthly;

  /// No description provided for @historyStatPresent.
  ///
  /// In uz, this message translates to:
  /// **'Ishga chiqqan'**
  String get historyStatPresent;

  /// No description provided for @historyStatLate.
  ///
  /// In uz, this message translates to:
  /// **'Ishga kechikkan'**
  String get historyStatLate;

  /// No description provided for @historyStatAvgArrival.
  ///
  /// In uz, this message translates to:
  /// **'O‘rtacha kelish'**
  String get historyStatAvgArrival;

  /// No description provided for @historyStatWorked.
  ///
  /// In uz, this message translates to:
  /// **'Jami ishlagan'**
  String get historyStatWorked;

  /// No description provided for @historyUnitDays.
  ///
  /// In uz, this message translates to:
  /// **'kun'**
  String get historyUnitDays;

  /// No description provided for @historyUnitHours.
  ///
  /// In uz, this message translates to:
  /// **'soat'**
  String get historyUnitHours;

  /// No description provided for @historyUnitMinutes.
  ///
  /// In uz, this message translates to:
  /// **'daqiqa'**
  String get historyUnitMinutes;

  /// No description provided for @historyToday.
  ///
  /// In uz, this message translates to:
  /// **'Bugun'**
  String get historyToday;

  /// No description provided for @historyYesterday.
  ///
  /// In uz, this message translates to:
  /// **'Kecha'**
  String get historyYesterday;

  /// No description provided for @historyEventArrived.
  ///
  /// In uz, this message translates to:
  /// **'Ishga keldi'**
  String get historyEventArrived;

  /// No description provided for @historyEventLunchOut.
  ///
  /// In uz, this message translates to:
  /// **'Tushlikka chiqdi'**
  String get historyEventLunchOut;

  /// No description provided for @historyEventLunchIn.
  ///
  /// In uz, this message translates to:
  /// **'Tushlikdan qaytdi'**
  String get historyEventLunchIn;

  /// No description provided for @historyEventLeft.
  ///
  /// In uz, this message translates to:
  /// **'Ishdan ketdi'**
  String get historyEventLeft;

  /// No description provided for @historyError.
  ///
  /// In uz, this message translates to:
  /// **'Ma’lumotni yuklab bo‘lmadi. Qayta urinib ko‘ring.'**
  String get historyError;

  /// No description provided for @notificationsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha bildirishnomalar yo‘q'**
  String get notificationsEmpty;

  /// No description provided for @notificationsError.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalarni yuklab bo‘lmadi. Qayta urinib ko‘ring.'**
  String get notificationsError;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In uz, this message translates to:
  /// **'Barchasini o‘qilgan deb belgilash'**
  String get notificationsMarkAllRead;

  /// No description provided for @profilePhotoPromptTitle.
  ///
  /// In uz, this message translates to:
  /// **'Iltimos, skanerlashdan o‘tish uchun profilingiz uchun shaxsiy rasmingizni o‘rnating!'**
  String get profilePhotoPromptTitle;

  /// No description provided for @profilePhotoUploadLabel.
  ///
  /// In uz, this message translates to:
  /// **'Rasm yuklash'**
  String get profilePhotoUploadLabel;

  /// No description provided for @profilePhotoUploadButton.
  ///
  /// In uz, this message translates to:
  /// **'Yuklash'**
  String get profilePhotoUploadButton;

  /// No description provided for @profileUsernameFallback.
  ///
  /// In uz, this message translates to:
  /// **'Username'**
  String get profileUsernameFallback;

  /// No description provided for @profileUploadFailed.
  ///
  /// In uz, this message translates to:
  /// **'Rasm yuklanmadi. Qayta urinib ko‘ring.'**
  String get profileUploadFailed;

  /// No description provided for @profilePickFailed.
  ///
  /// In uz, this message translates to:
  /// **'Rasmni tanlab bo‘lmadi.'**
  String get profilePickFailed;

  /// No description provided for @commonCancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get commonCancel;

  /// No description provided for @commonError.
  ///
  /// In uz, this message translates to:
  /// **'Nimadir xato ketdi. Birozdan so‘ng qayta urinib ko‘ring.'**
  String get commonError;

  /// No description provided for @networkError.
  ///
  /// In uz, this message translates to:
  /// **'Internet aloqasi yo‘q. Ulanishni tekshiring.'**
  String get networkError;

  /// No description provided for @vpnBlockedTitle.
  ///
  /// In uz, this message translates to:
  /// **'VPN aniqlandi'**
  String get vpnBlockedTitle;

  /// No description provided for @vpnBlockedBody.
  ///
  /// In uz, this message translates to:
  /// **'Davomat xavfsizligi uchun ilovadan VPN bilan foydalanish mumkin emas. Davom etish uchun VPN’ni o‘chiring.'**
  String get vpnBlockedBody;

  /// No description provided for @vpnRecheck.
  ///
  /// In uz, this message translates to:
  /// **'Qayta tekshirish'**
  String get vpnRecheck;

  /// No description provided for @onbWelcomeTitle.
  ///
  /// In uz, this message translates to:
  /// **'Xush kelibsiz!'**
  String get onbWelcomeTitle;

  /// No description provided for @onbWelcomeSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Bu ilova orqali ishga kelish va ketishingizni qayd etasiz. Birinchi kirishda bir martalik sozlash kerak — bu 2 daqiqa vaqt oladi.'**
  String get onbWelcomeSubtitle;

  /// No description provided for @onbRoleEmployee.
  ///
  /// In uz, this message translates to:
  /// **'Xodim'**
  String get onbRoleEmployee;

  /// No description provided for @onbContinue.
  ///
  /// In uz, this message translates to:
  /// **'Davom etish'**
  String get onbContinue;

  /// No description provided for @onbPermissionsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ruxsatlar'**
  String get onbPermissionsTitle;

  /// No description provided for @onbPermissionsSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Ilova ishlashi uchun ikkita ruxsat zarur.'**
  String get onbPermissionsSubtitle;

  /// No description provided for @onbPermLocationTitle.
  ///
  /// In uz, this message translates to:
  /// **'Joylashuv (GPS)'**
  String get onbPermLocationTitle;

  /// No description provided for @onbPermLocationDesc.
  ///
  /// In uz, this message translates to:
  /// **'Ish hududida ekaningizni tekshirish uchun'**
  String get onbPermLocationDesc;

  /// No description provided for @onbPermCameraTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kamera'**
  String get onbPermCameraTitle;

  /// No description provided for @onbPermCameraDesc.
  ///
  /// In uz, this message translates to:
  /// **'Face ID orqali shaxsni tasdiqlash uchun'**
  String get onbPermCameraDesc;

  /// No description provided for @onbGrant.
  ///
  /// In uz, this message translates to:
  /// **'Ruxsat berish'**
  String get onbGrant;

  /// No description provided for @onbPasswordTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi parol yarating'**
  String get onbPasswordTitle;

  /// No description provided for @onbPasswordSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Kadrlar bo‘limi bergan vaqtinchalik parol o‘rniga o‘z parolingizni o‘rnating.'**
  String get onbPasswordSubtitle;

  /// No description provided for @onbPasswordOldLabel.
  ///
  /// In uz, this message translates to:
  /// **'Eski parol'**
  String get onbPasswordOldLabel;

  /// No description provided for @onbPasswordLabel.
  ///
  /// In uz, this message translates to:
  /// **'Yangi parol'**
  String get onbPasswordLabel;

  /// No description provided for @onbPasswordConfirmLabel.
  ///
  /// In uz, this message translates to:
  /// **'Yangi parolni tasdiqlang'**
  String get onbPasswordConfirmLabel;

  /// No description provided for @onbPasswordMismatch.
  ///
  /// In uz, this message translates to:
  /// **'Parollar mos kelmadi'**
  String get onbPasswordMismatch;

  /// No description provided for @onbRuleMinLength.
  ///
  /// In uz, this message translates to:
  /// **'Kamida 8 belgi'**
  String get onbRuleMinLength;

  /// No description provided for @onbRuleUpper.
  ///
  /// In uz, this message translates to:
  /// **'Katta harf (A–Z)'**
  String get onbRuleUpper;

  /// No description provided for @onbRuleLower.
  ///
  /// In uz, this message translates to:
  /// **'Kichik harf (a–z)'**
  String get onbRuleLower;

  /// No description provided for @onbRuleDigit.
  ///
  /// In uz, this message translates to:
  /// **'Raqam (0–9)'**
  String get onbRuleDigit;

  /// No description provided for @onbRuleSpecial.
  ///
  /// In uz, this message translates to:
  /// **'Maxsus belgi (!@#\$%...)'**
  String get onbRuleSpecial;

  /// No description provided for @onbImageTitle.
  ///
  /// In uz, this message translates to:
  /// **'Shaxsiy rasmini o‘rnating'**
  String get onbImageTitle;

  /// No description provided for @onbImageSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Bu rasm sizning asosiy suratingiz bo‘ladi. Har safar kirishda yuzingiz shu rasm bilan tekshiriladi.'**
  String get onbImageSubtitle;

  /// No description provided for @onbImageUpload.
  ///
  /// In uz, this message translates to:
  /// **'Rasm yuklash'**
  String get onbImageUpload;

  /// No description provided for @onbImageHint.
  ///
  /// In uz, this message translates to:
  /// **'Yuzingizni to‘liq ko‘rinsin'**
  String get onbImageHint;

  /// No description provided for @onbFaceTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yuzni tekshirish'**
  String get onbFaceTitle;

  /// No description provided for @onbFaceSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Yuzingiz profil rasmi bilan solishtiriladi — mos kelsa, dasturga kiritilasiz.'**
  String get onbFaceSubtitle;

  /// No description provided for @onbFaceStart.
  ///
  /// In uz, this message translates to:
  /// **'Skanerlashni boshlash'**
  String get onbFaceStart;

  /// No description provided for @onbDoneTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hammasi tayyor!'**
  String get onbDoneTitle;

  /// No description provided for @onbDoneSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Endi davomatingizni qayd etishingiz mumkin. Har kuni ishga kelganda «Ishga keldim» tugmasini suring.'**
  String get onbDoneSubtitle;

  /// No description provided for @onbDoneStart.
  ///
  /// In uz, this message translates to:
  /// **'Ishni boshlash'**
  String get onbDoneStart;

  /// No description provided for @offlineAttendanceQueued.
  ///
  /// In uz, this message translates to:
  /// **'Internet yo‘q. Davomat saqlandi, ulanish tiklanganda yuboriladi.'**
  String get offlineAttendanceQueued;

  /// No description provided for @offlineOutsideGeofence.
  ///
  /// In uz, this message translates to:
  /// **'Siz ish joyida emassiz. Davomat saqlanmadi.'**
  String get offlineOutsideGeofence;

  /// No description provided for @offlineFaceMismatch.
  ///
  /// In uz, this message translates to:
  /// **'Yuz mos kelmadi. Davomat saqlanmadi.'**
  String get offlineFaceMismatch;

  /// No description provided for @offlineNoGeozone.
  ///
  /// In uz, this message translates to:
  /// **'Ish joyi ma’lumoti yuklanmagan. Avval internetga ulaning.'**
  String get offlineNoGeozone;

  /// No description provided for @offlineNoSecret.
  ///
  /// In uz, this message translates to:
  /// **'Oflayn rejim sozlanmagan. Avval internetga ulaning.'**
  String get offlineNoSecret;

  /// No description provided for @offlinePendingCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta davomat yuborilmadi'**
  String offlinePendingCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'uz':
      {
        switch (locale.scriptCode) {
          case 'Cyrl':
            return AppLocalizationsUzCyrl();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
