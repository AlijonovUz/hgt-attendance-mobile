import 'package:geolocator/geolocator.dart';

/// Qurilma joylashuvi (GPS) — davomat belgilashda koordinatalar uchun.
///
/// `geolocator` ustiga yupqa qatlam: xizmat yoqilganini + ruxsatni tekshiradi,
/// so‘ng joriy koordinatani qaytaradi. Ruxsat berilmasa [LocationException].
class LocationService {
  const LocationService();

  /// Joriy koordinata. Ruxsat/xizmat muammosida [LocationException] otadi.
  /// GPS o‘chiq bo‘lsa `serviceDisabled: true` bilan otiladi — UI yoqish
  /// dialogini ko‘rsatadi.
  Future<({double latitude, double longitude})> current() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException.serviceDisabled();
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

  /// Qurilma GPS sozlamalarini ochadi (foydalanuvchi yoqishi uchun).
  /// Sozlama ekrani ochilsa `true` qaytaradi.
  Future<bool> openSettings() => Geolocator.openLocationSettings();
}

/// Joylashuvni olishdagi xato (ruxsat/xizmat).
class LocationException implements Exception {
  const LocationException([this.message = 'Joylashuv aniqlanmadi'])
      : serviceDisabled = false;

  /// GPS xizmati o‘chiq — UI yoqish dialogini ko‘rsatadi.
  const LocationException.serviceDisabled([
    this.message = 'Joylashuv xizmati o‘chiq',
  ]) : serviceDisabled = true;

  final String message;

  /// `true` bo‘lsa — sabab GPS o‘chiqligi (ruxsat emas).
  final bool serviceDisabled;
}
