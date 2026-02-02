import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/profile_model.dart';

abstract class LocalStorageDataSource {
  Future<List<ProfileModel>> getProfiles();
  Future<void> saveProfiles(List<ProfileModel> profiles);
  Future<int?> getActiveProfileId();
  Future<void> setActiveProfileId(int profileId);
}

class LocalStorageDataSourceImpl implements LocalStorageDataSource {
  final SharedPreferences sharedPreferences;

  LocalStorageDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<ProfileModel>> getProfiles() async {
    final profilesJson = sharedPreferences.getString(AppConstants.profilesKey);
    
    if (profilesJson == null) {
      // Return default profiles
      return List.generate(
        AppConstants.profileCount,
        (index) => ProfileModel.defaultProfile(index + 1),
      );
    }

    try {
      final List<dynamic> profilesList = json.decode(profilesJson);
      return profilesList
          .map((json) => ProfileModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If parsing fails, return default profiles
      return List.generate(
        AppConstants.profileCount,
        (index) => ProfileModel.defaultProfile(index + 1),
      );
    }
  }

  @override
  Future<void> saveProfiles(List<ProfileModel> profiles) async {
    final profilesJson = json.encode(
      profiles.map((profile) => profile.toJson()).toList(),
    );
    await sharedPreferences.setString(AppConstants.profilesKey, profilesJson);
  }

  @override
  Future<int?> getActiveProfileId() async {
    return sharedPreferences.getInt(AppConstants.activeProfileIdKey);
  }

  @override
  Future<void> setActiveProfileId(int profileId) async {
    await sharedPreferences.setInt(AppConstants.activeProfileIdKey, profileId);
  }
}

