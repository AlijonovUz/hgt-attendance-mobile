import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Offline davomat vaqtini imzolash (`mobile_offline_docs.md` kelishuvi).
///
/// `signature = HMAC_SHA256(created_at, offline_secret)` → kichik harfli (hex)
/// satr. `created_at` — lokal vaqt ISO8601 + zona offseti bilan (UTC EMAS).
class HmacSigner {
  const HmacSigner();

  /// [createdAt] (ISO8601 string) ni [secret] kaliti bilan HMAC-SHA256 imzolaydi.
  String sign(String createdAt, String secret) {
    final hmac = Hmac(sha256, utf8.encode(secret));
    return hmac.convert(utf8.encode(createdAt)).toString();
  }

  /// Lokal vaqtni ISO8601 + zona offseti (`+05:00`) ko‘rinishida formatlaydi.
  /// `DateTime.toIso8601String()` lokal vaqtga offset qo‘shmaydi — shu yerda
  /// `timeZoneOffset`dan quramiz, backend kelajak/eskirgan tekshiruvi to‘g‘ri
  /// ishlashi uchun.
  static String formatLocalIso(DateTime time) {
    final local = time.toLocal();
    final base = local.toIso8601String().split('.').first; // sekundagacha
    final offset = local.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final abs = offset.abs();
    final hh = abs.inHours.toString().padLeft(2, '0');
    final mm = (abs.inMinutes % 60).toString().padLeft(2, '0');
    return '$base$sign$hh:$mm';
  }
}
