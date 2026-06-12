part of 'locale_bloc.dart';

sealed class LocaleEvent extends Equatable {
  const LocaleEvent();

  @override
  List<Object?> get props => [];
}

/// Foydalanuvchi tilni almashtirdi.
class LocaleChanged extends LocaleEvent {
  const LocaleChanged(this.language);

  final AppLanguage language;

  @override
  List<Object?> get props => [language];
}
