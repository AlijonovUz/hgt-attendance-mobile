import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/services/storage_service.dart';

part 'theme_event.dart';

/// Ilova tema rejimini (light / dark / system) boshqaradi va saqlaydi.
///
/// Login’dagi Yorug‘/Qorong‘i toggle’i [ThemeModeSelected] yuboradi; tanlov
/// diskga yoziladi va `MaterialApp.themeMode` shu blocdan o‘qiladi.
class ThemeBloc extends Bloc<ThemeEvent, ThemeMode> {
  ThemeBloc({required StorageService storage})
      : _storage = storage,
        super(_decode(storage.getString(StorageKeys.themeMode))) {
    on<ThemeModeSelected>(_onSelected);
  }

  final StorageService _storage;

  Future<void> _onSelected(
    ThemeModeSelected event,
    Emitter<ThemeMode> emit,
  ) async {
    if (event.mode == state) return;
    emit(event.mode);
    await _storage.setString(StorageKeys.themeMode, _encode(event.mode));
  }

  static ThemeMode _decode(String? raw) => switch (raw) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  static String _encode(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
}
