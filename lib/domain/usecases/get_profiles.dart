import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class GetProfiles {
  final ProfileRepository repository;

  GetProfiles(this.repository);

  Future<List<Profile>> call() async {
    return await repository.getProfiles();
  }
}

