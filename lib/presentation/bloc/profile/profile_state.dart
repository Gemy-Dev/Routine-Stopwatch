import 'package:equatable/equatable.dart';
import '../../../domain/entities/profile.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfilesLoaded extends ProfileState {
  final List<Profile> profiles;
  final Profile? activeProfile;
  
  const ProfilesLoaded({
    required this.profiles,
    this.activeProfile,
  });
  
  @override
  List<Object?> get props => [profiles, activeProfile];
}

class ProfileUpdated extends ProfileState {
  final List<Profile> profiles;
  final Profile? activeProfile;
  
  const ProfileUpdated({
    required this.profiles,
    this.activeProfile,
  });
  
  @override
  List<Object?> get props => [profiles, activeProfile];
}

class ProfileError extends ProfileState {
  final String message;
  
  const ProfileError(this.message);
  
  @override
  List<Object?> get props => [message];
}

