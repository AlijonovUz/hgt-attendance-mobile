import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../app/bloc/session_bloc.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/app_notification.dart';

/// Real-time bildirishnoma WebSocket xizmati (singleton).
///
/// Oqim: `POST /tickets/` → bir martalik ticket → `wss://{host}/ws/notifications/
/// ?ticket=...` ga ulanadi → kelgan JSON xabarlarni [AppNotification]ga aylantirib
/// [notifications] broadcast oqimiga uzatadi. Har bir live `NotificationBloc` shu
/// oqimga obuna bo‘ladi (ro‘yxat + count’ni jonli yangilaydi).
///
/// Hayot sikli: `authenticated` → ulanadi, `unauthenticated` → uziladi.
/// Ulanish uzilsa eksponensial backoff bilan qayta urinadi (auth bo‘lsa).
class NotificationSocketService {
  NotificationSocketService({
    required DioClient client,
    required SessionBloc session,
  })  : _client = client,
        _session = session;

  final DioClient _client;
  final SessionBloc _session;

  final _controller = StreamController<AppNotification>.broadcast();

  /// Kelgan jonli bildirishnomalar oqimi (broadcast — ko‘p obunachi).
  Stream<AppNotification> get notifications => _controller.stream;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _channelSub;
  StreamSubscription<SessionState>? _sessionSub;
  Timer? _reconnectTimer;
  int _retry = 0;
  bool _started = false;
  bool _disposed = false;

  static const _maxBackoff = Duration(seconds: 30);

  /// Bir marta (bootstrap) chaqiriladi — auth holatini tinglaydi va kerak
  /// bo‘lsa darhol ulanadi.
  void start() {
    if (_started) return;
    _started = true;

    _sessionSub = _session.stream.listen((state) {
      if (state.isAuthenticated) {
        _connect();
      } else if (state.isUnauthenticated) {
        _disconnect();
      }
    });
    if (_session.state.isAuthenticated) _connect();
  }

  Future<void> _connect() async {
    if (_disposed || _channel != null) return;
    try {
      final ticket = await _fetchTicket();
      if (ticket == null || ticket.isEmpty) {
        _scheduleReconnect();
        return;
      }
      final channel = WebSocketChannel.connect(_wsUri(ticket));
      _channel = channel;
      await channel.ready; // ulanishni kutamiz; muvaffaqiyatsiz bo‘lsa otadi.

      _retry = 0;
      _channelSub = channel.stream.listen(
        _onData,
        onError: (_) => _onClosed(),
        onDone: _onClosed,
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint('NotificationSocketService._connect xatosi: $e');
      _channel = null;
      _scheduleReconnect();
    }
  }

  Future<String?> _fetchTicket() async {
    try {
      final response = await _client.post(ApiConstants.notificationsTicket);
      final data = response.data;
      final map = data is Map ? data.cast<String, dynamic>() : const {};
      final src = map['data'] is Map
          ? (map['data'] as Map).cast<String, dynamic>()
          : map;
      return src['ticket']?.toString();
    } catch (e) {
      debugPrint('NotificationSocketService._fetchTicket xatosi: $e');
      return null;
    }
  }

  Uri _wsUri(String ticket) {
    final base = Uri.parse(ApiConstants.baseUrl);
    return Uri(
      scheme: base.scheme == 'https' ? 'wss' : 'ws',
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: ApiConstants.notificationsWsPath,
      queryParameters: {'ticket': ticket},
    );
  }

  void _onData(dynamic raw) {
    final notification = _parse(raw);
    if (notification != null) _controller.add(notification);
  }

  /// Kelgan JSON’ni [AppNotification]ga aylantiradi. Backend bitta tilda
  /// (`title`/`message`) yoki uch tilda (`title_uz_latn` …) yuborishi mumkin —
  /// ikkalasi ham qo‘llanadi. `{type, message:{…}}` o‘ralgan bo‘lsa ichidan oladi.
  AppNotification? _parse(dynamic raw) {
    try {
      final decoded = raw is String ? jsonDecode(raw) : raw;
      if (decoded is! Map) return null;
      var map = decoded.cast<String, dynamic>();

      // Channels `{type, message:{…}}` o‘rovi — ichidagi obyektni olamiz.
      if (map['id'] == null && map['message'] is Map) {
        map = (map['message'] as Map).cast<String, dynamic>();
      }

      final id = map['id']?.toString() ?? '';
      if (id.isEmpty) return null;

      String s(Object? v) => v?.toString().trim() ?? '';
      final titleLatn = s(map['title_uz_latn']).isNotEmpty
          ? s(map['title_uz_latn'])
          : s(map['title']);
      final titleCyrl =
          s(map['title_uz_cyrl']).isNotEmpty ? s(map['title_uz_cyrl']) : titleLatn;
      final titleRu = s(map['title_ru']).isNotEmpty ? s(map['title_ru']) : titleLatn;

      final msgLatn = s(map['message_uz_latn']).isNotEmpty
          ? s(map['message_uz_latn'])
          : s(map['message']);
      final msgCyrl = s(map['message_uz_cyrl']).isNotEmpty
          ? s(map['message_uz_cyrl'])
          : msgLatn;
      final msgRu =
          s(map['message_ru']).isNotEmpty ? s(map['message_ru']) : msgLatn;

      return AppNotification(
        id: id,
        titleUzLatn: titleLatn,
        titleUzCyrl: titleCyrl,
        titleRu: titleRu,
        messageUzLatn: msgLatn,
        messageUzCyrl: msgCyrl,
        messageRu: msgRu,
        isRead: map['is_read'] == true,
        createdAt: DateTime.tryParse(s(map['created_at'])),
      );
    } catch (e) {
      debugPrint('NotificationSocketService._parse xatosi: $e');
      return null;
    }
  }

  void _onClosed() {
    _channelSub?.cancel();
    _channelSub = null;
    _channel = null;
    if (_session.state.isAuthenticated) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed || _reconnectTimer != null) return;
    if (!_session.state.isAuthenticated) return;
    final seconds = (1 << _retry).clamp(1, _maxBackoff.inSeconds);
    _retry = (_retry + 1).clamp(0, 5);
    _reconnectTimer = Timer(Duration(seconds: seconds), () {
      _reconnectTimer = null;
      _connect();
    });
  }

  Future<void> _disconnect() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _retry = 0;
    await _channelSub?.cancel();
    _channelSub = null;
    await _channel?.sink.close();
    _channel = null;
  }

  Future<void> dispose() async {
    _disposed = true;
    await _sessionSub?.cancel();
    await _disconnect();
    await _controller.close();
  }
}
