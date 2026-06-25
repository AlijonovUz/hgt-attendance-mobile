import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Tarmoq holati — `connectivity_plus` ustida yupqa qatlam.
///
/// [isConnected] hozirgi holatni bir martalik tekshiradi (davomat
/// belgilashda online/offline shoxlash uchun). [onConnected] — offline→online
/// o‘tishlarini uzatadi (sync dvigateli shu oqimda navbatni drenajlaydi).
///
/// Eslatma: `connectivity_plus` faqat interfeys borligini biladi (real internet
/// kafolatlamaydi) — offline davomat uchun bu yetarli (so‘rov baribir
/// urinilganda tarmoq xatosi navbatda qoldiradi).
class ConnectivityService {
  ConnectivityService([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Future<bool> isConnected() async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  /// `true` chiqsa — qurilma onlayn bo‘ldi (offline→online o‘tish ham shu
  /// oqimda keladi). Faqat o‘zgarishlar emas, har bir natijani uzatadi.
  Stream<bool> get onStatusChanged =>
      _connectivity.onConnectivityChanged.map(_hasConnection);

  bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}
