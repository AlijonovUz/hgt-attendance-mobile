import 'package:connectivity_plus/connectivity_plus.dart';

/// Tarmoq holati (online/offline) — `connectivity_plus` ustiga yupqa qatlam.
///
/// `connectivity_plus` faqat interfeys turini (wifi/mobil/yo‘q) biladi, haqiqiy
/// internet yetib borishini emas — offline davomat uchun bu yetarli (so‘rov
/// baribir `Dio` orqali yuborilganда xato bo‘lsa navbatda qoladi).
class ConnectivityService {
  ConnectivityService([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// Hozir tarmoqqa ulanganmi (interfeys mavjudmi).
  Future<bool> isConnected() async {
    final results = await _connectivity.checkConnectivity();
    return _isOnline(results);
  }

  /// Ulanish holati o‘zgarganda `true`/`false` emit qiladi (takrorlar olib
  /// tashlanadi). Sinxron menejeri shuni tinglaydi.
  Stream<bool> get onStatusChange =>
      _connectivity.onConnectivityChanged.map(_isOnline).distinct();

  bool _isOnline(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}
