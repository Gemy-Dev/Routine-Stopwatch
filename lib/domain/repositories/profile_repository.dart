import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<List<Profile>> getProfiles();
  Future<void> saveProfile(Profile profile);
  Future<void> setActiveProfile(int profileId);
  Future<Profile?> getActiveProfile();
}

