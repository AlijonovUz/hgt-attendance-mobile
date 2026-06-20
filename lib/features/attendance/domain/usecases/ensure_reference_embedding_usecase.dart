import '../../../profile/domain/entities/profile.dart';
import '../repository/face_reference_repository.dart';

/// Profil rasmidan offline yuz moslik uchun reference embeddingni tayyorlaydi
/// (online, app kirib profil yuklangach va rasm PATCH’idan keyin).
class EnsureReferenceEmbeddingUseCase {
  const EnsureReferenceEmbeddingUseCase(this._repository);

  final FaceReferenceRepository _repository;

  Future<void> call(Profile profile) => _repository.ensureFor(
        profileId: profile.id,
        faceImageUrl: profile.faceImage,
      );
}
