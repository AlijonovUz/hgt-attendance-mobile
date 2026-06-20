import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Offline davomat vaqtini imzolaydi — backend bilan kelishilgan xavfsizlik
/// protokoli (`mobile_offline_docs.md`).
///
/// `signature = HMAC_SHA256(createdAtIso, offlineSecret)`, natija lowercase hex.
/// `createdAtIso` — swipe momentidagi lokal vaqt ISO 8601 + timezone offset
/// (mas. `2026-06-17T08:30:00+05:00`). Imzo va vaqt birgalikda `POST attendance`
/// form-data’siga qo‘shiladi; backend imzoni qayta hisoblab moslikni tekshiradi.
///
/// MUHIM: imzolangan string keyin verbatim yuborilishi shart — qayta formatlash
/// imzoni buzadi. Shuning uchun `createdAtIso` queue’da o‘zgarmas saqlanadi.
String signCreatedAt(String createdAtIso, String offlineSecret) {
  final hmac = Hmac(sha256, utf8.encode(offlineSecret));
  return hmac.convert(utf8.encode(createdAtIso)).toString();
}

/// Lokal vaqtni `2026-06-17T08:30:00+05:00` ko‘rinishida (ISO 8601 + timezone
/// offset, millisekundsiz) qaytaradi — backend imzosi shu string ustidan
/// hisoblanadi (`mobile_offline_docs.md`).
String localIso8601(DateTime dt) {
  String two(int v) => v.abs().toString().padLeft(2, '0');
  final d = dt.toLocal();
  final date =
      '${d.year.toString().padLeft(4, '0')}-${two(d.month)}-${two(d.day)}';
  final time = '${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
  final off = d.timeZoneOffset;
  final sign = off.isNegative ? '-' : '+';
  final offset = '$sign${two(off.inHours)}:${two(off.inMinutes % 60)}';
  return '${date}T$time$offset';
}
