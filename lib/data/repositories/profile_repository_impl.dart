import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/local_storage_datasource.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final LocalStorageDataSource dataSource;

  ProfileRepositoryImpl(this.dataSource);

  @override
  Future<List<Profile>> getProfiles() async {
    final profiles = await dataSource.getProfiles();
    return profiles;
  }

  @override
  Future<void> saveProfile(Profile profile) async {
    final profiles = await dataSource.getProfiles();
    final profileModels = profiles.map<ProfileModel>((p) {
      if (p.id == profile.id) {
        return ProfileModel(
          id: profile.id,
          name: profile.name,
          triggerTime: profile.triggerTime,
          soundIndex: profile.soundIndex,
          cycleMultiplier: profile.cycleMultiplier,
          playUntilStopped: profile.playUntilStopped,
          isActive: profile.isActive,
        );
      }
      return p; // p is already ProfileModel
    }).toList();
    
    await dataSource.saveProfiles(profileModels);
  }

  @override
  Future<void> setActiveProfile(int profileId) async {
    final profiles = await dataSource.getProfiles();
    final updatedProfiles = profiles.map<ProfileModel>((p) {
      // ProfileModel.copyWith returns ProfileModel
      return p.copyWith(isActive: p.id == profileId);
    }).toList();
    
    await dataSource.saveProfiles(updatedProfiles);
    await dataSource.setActiveProfileId(profileId);
  }

  @override
  Future<Profile?> getActiveProfile() async {
    final activeProfileId = await dataSource.getActiveProfileId();
    if (activeProfileId == null) {
      final profiles = await getProfiles();
      return profiles.firstWhere(
        (p) => p.isActive,
        orElse: () => profiles.first,
      );
    }
    
    final profiles = await getProfiles();
    try {
      return profiles.firstWhere((p) => p.id == activeProfileId);
    } catch (e) {
      return profiles.first;
    }
  }
}

