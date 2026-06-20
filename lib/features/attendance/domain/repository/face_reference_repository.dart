/// Offline yuz moslik uchun reference embedding (profil rasmidan).
abstract interface class FaceReferenceRepository {
  /// [faceImageUrl]dan reference embeddingni hisoblab lokalga saqlaydi (online).
  /// Cache kaliti `profileId|faceImageUrl` — URL o‘zgarmasa qayta hisoblamaydi.
  /// Rasm yo‘q/yuz topilmasa hech nima qilmaydi.
  Future<void> ensureFor({
    required String profileId,
    required String? faceImageUrl,
  });

  /// Cache’langan reference embedding (yo‘q bo‘lsa `null`).
  List<double>? cachedEmbedding();
}
