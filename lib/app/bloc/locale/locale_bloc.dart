import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/services/storage_service.dart';

part 'locale_event.dart';

/// Ilova qo‘llab-quvvatlaydigan tillar — login’dagi til dropdown’i shu ro‘yxatdan
/// quriladi. Har biri [Locale], saqlash tegi va ko‘rsatiladigan nomni biriktiradi.
enum AppLanguage {
  uzLatin('uz', Locale('uz'), 'Uzbek'),
  uzCyrillic('uz_Cyrl', Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl'), 'Узбек'),
  russian('ru', Locale('ru'), 'Русский');

  const AppLanguage(this.tag, this.locale, this.label);

  /// Diskka yoziladigan barqaror identifikator.
  final String tag;
  final Locale locale;

  /// Dropdown’da ko‘rsatiladigan nom (har doim o‘z tilida — tarjima qilinmaydi).
  final String label;

  /// Toolbar’dagi qisqa kod (masalan `UZ`, `RU`).
  String get shortCode => this == russian ? 'RU' : 'UZ';

  static AppLanguage fromTag(String? tag) =>
      AppLanguage.values.firstWhere((l) => l.tag == tag, orElse: () => uzLatin);
}

/// Joriy ilova tilini boshqaradi va saqlaydi (`MaterialApp.locale` manbai).
class LocaleBloc extends Bloc<LocaleEvent, AppLanguage> {
  LocaleBloc({required StorageService storage})
      : _storage = storage,
        super(AppLanguage.fromTag(storage.getString(StorageKeys.languageCode))) {
    on<LocaleChanged>(_onChanged);
  }

  final StorageService _storage;

  Future<void> _onChanged(LocaleChanged event, Emitter<AppLanguage> emit) async {
    if (event.language == state) return;
    emit(event.language);
    await _storage.setString(StorageKeys.languageCode, event.language.tag);
  }
}
