import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class SaveProfile {
  final ProfileRepository repository;

  SaveProfile(this.repository);

  Future<void> call(Profile profile) async {
    await repository.saveProfile(profile);
  }
}

