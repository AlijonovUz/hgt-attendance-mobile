import '../entities/geozone.dart';

/// Geozona domeni shartnomasi. Xatolarda `Failure` `throw` qiladi.
abstract interface class GeozoneRepository {
  /// Barcha geozonalarni oladi (online).
  Future<List<Geozone>> fetchAll();
}
