import '../repositories/profile_repository.dart';

class SetActiveProfile {
  final ProfileRepository repository;

  SetActiveProfile(this.repository);

  Future<void> call(int profileId) async {
    await repository.setActiveProfile(profileId);
  }
}

