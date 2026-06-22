/// Bitta bildirishnoma (pure Dart — Flutter/JSON importlari yo‘q).
///
/// Sarlavha/matn backend’da uch tilda keladi (`*_uz_latn` / `*_uz_cyrl` /
/// `*_ru`). [title] / [message] joriy til kodi bo‘yicha mosini tanlaydi va
/// bo‘sh bo‘lsa boshqa tillarga qaytadi (graceful fallback).
class AppNotification {
  const AppNotification({
    required this.id,
    required this.titleUzLatn,
    required this.titleUzCyrl,
    required this.titleRu,
    required this.messageUzLatn,
    required this.messageUzCyrl,
    required this.messageRu,
    required this.isRead,
    this.createdAt,
  });

  final String id;
  final String titleUzLatn;
  final String titleUzCyrl;
  final String titleRu;
  final String messageUzLatn;
  final String messageUzCyrl;
  final String messageRu;
  final bool isRead;
  final DateTime? createdAt;

  /// Joriy [languageCode]/[scriptCode] bo‘yicha sarlavha.
  String title(String languageCode, String? scriptCode) =>
      _pick(languageCode, scriptCode, titleUzLatn, titleUzCyrl, titleRu);

  /// Joriy [languageCode]/[scriptCode] bo‘yicha matn.
  String message(String languageCode, String? scriptCode) =>
      _pick(languageCode, scriptCode, messageUzLatn, messageUzCyrl, messageRu);

  static String _pick(
    String languageCode,
    String? scriptCode,
    String uzLatn,
    String uzCyrl,
    String ru,
  ) {
    final preferred = switch (languageCode) {
      'ru' => ru,
      'uz' when scriptCode == 'Cyrl' => uzCyrl,
      _ => uzLatn,
    };
    if (preferred.trim().isNotEmpty) return preferred.trim();
    // Bo‘sh tarjima — birinchi to‘ldirilganiga qaytamiz.
    for (final v in [uzLatn, uzCyrl, ru]) {
      if (v.trim().isNotEmpty) return v.trim();
    }
    return '';
  }

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        titleUzLatn: titleUzLatn,
        titleUzCyrl: titleUzCyrl,
        titleRu: titleRu,
        messageUzLatn: messageUzLatn,
        messageUzCyrl: messageUzCyrl,
        messageRu: messageRu,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );
}

/// Sahifalangan bildirishnomalar javobi (`count` / `next` mavjudligi).
class NotificationPage {
  const NotificationPage({
    required this.items,
    required this.count,
    required this.hasNext,
  });

  final List<AppNotification> items;

  /// Umumiy yozuvlar soni (backend `count`).
  final int count;

  /// Keyingi sahifa bormi (backend `next != null`).
  final bool hasNext;
}
