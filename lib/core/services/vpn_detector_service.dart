import 'dart:async';

import 'package:vpn_connection_detector/vpn_connection_detector.dart';

/// VPN holatini kuzatuvchi xizmat (DI singleton).
///
/// `vpn_connection_detector` paketini o‘rab beradi: native (iOS/Android) yo‘l
/// bilan tizim yoki uchinchi tomon VPN ulanishini real vaqtda aniqlaydi.
/// [stream] `true` (VPN yoqilgan) / `false` (o‘chiq) qiymatlarini uzatadi —
/// faqat o‘zgargan paytda (`distinct`). UI shu oqimni tinglab, VPN yoqilganda
/// bloklovchi oynani ko‘rsatadi.
class VpnDetectorService {
  VpnDetectorService() : _detector = VpnConnectionDetector();

  final VpnConnectionDetector _detector;

  /// VPN holati oqimi — `true` = ulangan, `false` = uzilgan. Faqat holat
  /// o‘zgarganda emit qiladi.
  Stream<bool> get stream => _detector.vpnConnectionStream
      .map((state) => state == VpnConnectionState.connected)
      .distinct();

  /// Bir martalik tekshiruv — masalan «Qayta tekshirish» tugmasi uchun.
  Future<bool> isActive() => VpnConnectionDetector.isVpnActive();

  void dispose() => _detector.dispose();
}
