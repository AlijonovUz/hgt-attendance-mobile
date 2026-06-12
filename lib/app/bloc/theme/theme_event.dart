part of 'theme_bloc.dart';

sealed class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

/// Foydalanuvchi tema rejimini tanladi (toggle).
class ThemeModeSelected extends ThemeEvent {
  const ThemeModeSelected(this.mode);

  final ThemeMode mode;

  @override
  List<Object?> get props => [mode];
}
