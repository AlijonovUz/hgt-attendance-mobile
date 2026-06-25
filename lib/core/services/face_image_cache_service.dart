import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/api_constants.dart';

/// Profil yuz rasmini qurilma xotirasiga (path_provider docs dir) bayt
/// ko‘rinishida yuklab olib, JPG fayl sifatida saqlaydi.
///
/// Offline-first oqim: ilovaga kirilganida `ProfileBloc` profilni oladi va
/// shu xizmat orqali rasmni lokalga keshlab qo‘yadi. Keyingi tushlik/kelib‑
/// ketish amallari (offline yuz tasdig‘i) shu fayldan o‘qiladi.
///
/// Yo‘l shabloni: `<docs>/face_images/<userId>.jpg`. Bayt‑bayt yozish
/// (`writeAsBytes`) — chunked nusxalashga qaraganda integrity nazorati
/// (`flush: true`) va o‘lcham tekshiruvi oddiyroq.
class FaceImageCacheService {
  FaceImageCacheService(this._dio);

  /// Interceptorsiz Dio — keshlanayotgan media tarmoq Bearer’iga muhtoj
  /// emas (rasm URL’i public yoki vaqtinchalik token bilan keladi).
  final Dio _dio;

  static const _dirName = 'face_images';

  /// Berilgan foydalanuvchi uchun keshlangan fayl mavjudligini tekshiradi.
  /// Qaytadi: mavjud bo‘lsa absolute path, aks holda `null`.
  Future<String?> cachedPathFor(String userId) async {
    if (userId.isEmpty) return null;
    final file = await _fileFor(userId);
    return await file.exists() ? file.path : null;
  }

  /// Kesh papkasidagi **eng oxirgi yangilangan** yuz rasmini qaytaradi (yo‘q
  /// bo‘lsa `null`). `cachedPathFor(userId)` null bo‘lganida zaxira sifatida
  /// ishlatiladi — JWT `user_id` claim profil `id`ga to‘liq mos kelmagan
  /// (yoki bo‘sh) holatda ham offline reference topiladi. Logout’da papka
  /// tozalanadi ([clearAll]) — shu sabab eng oxirgi fayl = joriy foydalanuvchi.
  Future<String?> anyCachedPath() async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory('${docs.path}${Platform.pathSeparator}$_dirName');
      if (!await dir.exists()) return null;
      final files = <File>[
        for (final e in dir.listSync())
          if (e is File && e.path.toLowerCase().endsWith('.jpg')) e,
      ];
      if (files.isEmpty) return null;
      files.sort(
        (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
      );
      return files.first.path;
    } catch (_) {
      return null;
    }
  }

  /// Rasm URL’ini bayt‑bayt yuklab olib, lokalga JPG sifatida yozadi.
  ///
  /// `faceImage` formati:
  ///   - `https?://...` → to‘liq URL
  ///   - `/media/...` yoki `media/...` → backend origin bilan birlashtiriladi
  ///   - bo‘sh / `null` → `null` qaytadi
  ///   - lokal fayl yo‘li (`/data/...`) → o‘zi qaytariladi (qayta yuklamaymiz)
  ///
  /// Xato (404, tarmoq) → `null`. Chaqiruvchi UI bloklamaydi.
  Future<String?> downloadAndStore({
    required String userId,
    required String faceImage,
  }) async {
    if (userId.isEmpty) return null;
    final src = faceImage.trim();
    if (src.isEmpty) return null;

    // Allaqachon lokal fayl bo‘lsa (rasm yuklash bosqichidan keyin), shuni
    // ko‘chirib qo‘yamiz (kanonik joyga).
    if (!src.startsWith('http') &&
        !src.startsWith('/media') &&
        !src.startsWith('media')) {
      final existing = File(src);
      if (await existing.exists()) {
        return _storeBytes(userId, await existing.readAsBytes());
      }
      return null;
    }

    final url = src.startsWith('http') ? src : _mediaUrl(src);

    // 1) Avatar (CachedNetworkImage) bilan bir xil kesh — URL kalit. Online:
    //    yuklab oladi va keshlaydi; offline: keshdagi faylni beradi. Avatar shu
    //    keshdan offline ko‘ringani uchun bu manba ishonchli (auth talab qilmaydi).
    try {
      final file = await DefaultCacheManager().getSingleFile(url);
      final bytes = await file.readAsBytes();
      if (bytes.isNotEmpty) return _storeBytes(userId, bytes);
    } catch (_) {
      // keshda yo‘q / offline yuklab bo‘lmadi — quyidagi Dio zaxirasiga o‘tamiz.
    }

    // 2) Zaxira — to‘g‘ridan-to‘g‘ri yuklab olish.
    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
      );
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) return null;
      return _storeBytes(userId, Uint8List.fromList(bytes));
    } on DioException {
      return null;
    }
  }

  /// Tashqi xizmatlar (`ProfileBloc.upload` muvaffaqiyatidan keyin) lokal
  /// faylni to‘g‘ridan‑to‘g‘ri yozish uchun.
  Future<String?> storeFromBytes(String userId, Uint8List bytes) =>
      _storeBytes(userId, bytes);

  /// Lokal fayldan baytlarni o‘qiydi (offline yuz matching/upload uchun).
  Future<Uint8List?> readBytes(String userId) async {
    final path = await cachedPathFor(userId);
    if (path == null) return null;
    return File(path).readAsBytes();
  }

  /// Logout/expire bosqichida tozalash uchun.
  Future<void> clear(String userId) async {
    if (userId.isEmpty) return;
    final file = await _fileFor(userId);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Butun yuz-rasm keshini tozalaydi (logout) — boshqa foydalanuvchi kirsa
  /// [anyCachedPath] eski rasmni qaytarmasligi uchun.
  Future<void> clearAll() async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory('${docs.path}${Platform.pathSeparator}$_dirName');
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (_) {}
  }

  Future<String> _storeBytes(String userId, Uint8List bytes) async {
    final file = await _fileFor(userId);
    await file.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<File> _fileFor(String userId) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}${Platform.pathSeparator}$_dirName');
    return File(
      '${dir.path}${Platform.pathSeparator}$userId.jpg',
    );
  }

  String _mediaUrl(String src) {
    final origin = ApiConstants.baseUrl.replaceFirst('/api', '');
    return '$origin${src.startsWith('/') ? '' : '/'}$src';
  }
}
