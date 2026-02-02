import 'package:equatable/equatable.dart';
import '../../../domain/entities/profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfiles extends ProfileEvent {
  const LoadProfiles();
}

class UpdateProfile extends ProfileEvent {
  final Profile profile;
  
  const UpdateProfile(this.profile);
  
  @override
  List<Object?> get props => [profile];
}

class SetActiveProfile extends ProfileEvent {
  final int profileId;
  
  const SetActiveProfile(this.profileId);
  
  @override
  List<Object?> get props => [profileId];
}

