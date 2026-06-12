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
