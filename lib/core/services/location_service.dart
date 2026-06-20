import 'package:geolocator/geolocator.dart';

/// Qurilma joylashuvi (GPS) — davomat belgilashda koordinatalar uchun.
///
/// `geolocator` ustiga yupqa qatlam: xizmat yoqilganini + ruxsatni tekshiradi,
/// so‘ng joriy koordinatani qaytaradi. Ruxsat berilmasa [LocationException].
class LocationService {
  const LocationService();

  /// Qurilmada joylashuv (GPS) xizmati yoqilganmi.
  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  /// Qurilmaning joylashuv sozlamalarini ochadi (foydalanuvchi GPS’ni yoqishi
  /// uchun). Android’da tizim sozlamalari, iOS’da ilova sozlamalari oynasi.
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  /// Joriy koordinata. Ruxsat/xizmat muammosida [LocationException] otadi.
  Future<({double latitude, double longitude})> current() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException('Joylashuv xizmati o‘chiq');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationException('Joylashuvga ruxsat berilmadi');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    return (latitude: position.latitude, longitude: position.longitude);
  }
}

/// Joylashuvni olishdagi xato (ruxsat/xizmat).
class LocationException implements Exception {
  const LocationException([this.message = 'Joylashuv aniqlanmadi']);
  final String message;
}
