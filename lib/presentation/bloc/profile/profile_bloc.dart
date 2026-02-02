import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routine_stopwatch/domain/entities/profile.dart';
import '../../../domain/usecases/get_profiles.dart';
import '../../../domain/usecases/save_profile.dart';
import '../../../domain/usecases/set_active_profile.dart' as usecase;
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfiles _getProfiles;
  final SaveProfile _saveProfile;
  final usecase.SetActiveProfile _setActiveProfile;

  ProfileBloc({
    required GetProfiles getProfiles,
    required SaveProfile saveProfile,
    required usecase.SetActiveProfile setActiveProfile,
  })  : _getProfiles = getProfiles,
        _saveProfile = saveProfile,
        _setActiveProfile = setActiveProfile,
        super(const ProfileInitial()) {
    on<LoadProfiles>(_onLoadProfiles);
    on<UpdateProfile>(_onUpdateProfile);
    on<SetActiveProfile>(_onSetActiveProfile);
  }

  Future<void> _onLoadProfiles(
    LoadProfiles event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final profiles = await _getProfiles();
      if (profiles.isEmpty) {
        emit(ProfileError('No profiles found'));
        return;
      }
      Profile? activeProfile;
      try {
        activeProfile = profiles.firstWhere((p) => p.isActive);
      } catch (_) {
        activeProfile = profiles.first;
      }
      emit(ProfilesLoaded(profiles: profiles, activeProfile: activeProfile));
    } catch (e) {
      emit(ProfileError('Failed to load profiles: $e'));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _saveProfile(event.profile);
      final profiles = await _getProfiles();
      if (profiles.isEmpty) {
        emit(ProfileError('No profiles found'));
        return;
      }
      Profile? activeProfile;
      try {
        activeProfile = profiles.firstWhere((p) => p.isActive);
      } catch (_) {
        activeProfile = profiles.first;
      }
      emit(ProfileUpdated(profiles: profiles, activeProfile: activeProfile));
    } catch (e) {
      emit(ProfileError('Failed to update profile: $e'));
    }
  }

  Future<void> _onSetActiveProfile(
    SetActiveProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _setActiveProfile(event.profileId);
      final profiles = await _getProfiles();
      if (profiles.isEmpty) {
        emit(ProfileError('No profiles found'));
        return;
      }
      Profile? activeProfile;
      try {
        activeProfile = profiles.firstWhere((p) => p.id == event.profileId);
      } catch (_) {
        activeProfile = profiles.first;
      }
      emit(ProfileUpdated(profiles: profiles, activeProfile: activeProfile));
    } catch (e) {
      emit(ProfileError('Failed to set active profile: $e'));
    }
  }
}

