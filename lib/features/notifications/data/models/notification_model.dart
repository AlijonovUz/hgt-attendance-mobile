import '../../domain/entities/app_notification.dart';

/// `/v1/notifications/` javobidagi bitta yozuvni parslaydi.
///
/// Sarlavha/matn uch tilda (`title_uz_latn` / `title_uz_cyrl` / `title_ru`,
/// `message_*`). `created_at` ISO-8601. Backend xom obyekt yoki konvert
/// (`{ data, success }`) qaytarishi mumkin — ikkalasi ham qo‘llanadi.
class NotificationModel {
  const NotificationModel({
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

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    String str(Object? v) => v == null ? '' : v.toString();

    DateTime? date(Object? v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    return NotificationModel(
      id: str(json['id']),
      titleUzLatn: str(json['title_uz_latn']),
      titleUzCyrl: str(json['title_uz_cyrl']),
      titleRu: str(json['title_ru']),
      messageUzLatn: str(json['message_uz_latn']),
      messageUzCyrl: str(json['message_uz_cyrl']),
      messageRu: str(json['message_ru']),
      isRead: json['is_read'] == true,
      createdAt: date(json['created_at']),
    );
  }

  AppNotification toEntity() => AppNotification(
        id: id,
        titleUzLatn: titleUzLatn,
        titleUzCyrl: titleUzCyrl,
        titleRu: titleRu,
        messageUzLatn: messageUzLatn,
        messageUzCyrl: messageUzCyrl,
        messageRu: messageRu,
        isRead: isRead,
        createdAt: createdAt,
      );
}

/// Sahifalangan ro‘yxat (`count` / `next` / `results`).
class NotificationPageModel {
  const NotificationPageModel({
    required this.items,
    required this.count,
    required this.hasNext,
  });

  final List<NotificationModel> items;
  final int count;
  final bool hasNext;

  factory NotificationPageModel.fromJson(Map<String, dynamic> json) {
    // Konvert bo‘lsa `data` ichidan, aks holda top-level’dan o‘qiymiz.
    final src = json['data'] is Map
        ? (json['data'] as Map).cast<String, dynamic>()
        : json;

    final rawResults = src['results'];
    final list = rawResults is List ? rawResults : const [];
    final items = list
        .whereType<Map>()
        .map((e) => NotificationModel.fromJson(e.cast<String, dynamic>()))
        .toList();

    final count = src['count'] is num
        ? (src['count'] as num).toInt()
        : items.length;

    return NotificationPageModel(
      items: items,
      count: count,
      hasNext: src['next'] != null,
    );
  }

  NotificationPage toEntity() => NotificationPage(
        items: items.map((m) => m.toEntity()).toList(),
        count: count,
        hasNext: hasNext,
      );
}
