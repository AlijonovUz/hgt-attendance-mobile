import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService() : _preferences = null;

  StorageService._(this._preferences);

  static Future<StorageService> persistent({Set<String>? allowList}) async {
    try {
      final preferences = await SharedPreferencesWithCache.create(
        cacheOptions: SharedPreferencesWithCacheOptions(allowList: allowList),
      );
      return StorageService._(preferences);
    } catch (_) {
      return StorageService();
    }
  }

  final SharedPreferencesWithCache? _preferences;
  final Map<String, String> _memoryStorage = <String, String>{};

  Future<void> setString(String key, String value) async {
    if (_preferences case final preferences?) {
      await preferences.setString(key, value);
      return;
    }
    _memoryStorage[key] = value;
  }

  String? getString(String key) {
    if (_preferences case final preferences?) {
      return preferences.getString(key);
    }
    return _memoryStorage[key];
  }

  Future<void> remove(String key) async {
    if (_preferences case final preferences?) {
      await preferences.remove(key);
      return;
    }
    _memoryStorage.remove(key);
  }
}
