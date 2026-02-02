import '../../domain/entities/profile.dart';
import '../../core/constants/app_constants.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.name,
    required super.triggerTime,
    required super.soundIndex,
    super.cycleMultiplier,
    required super.playUntilStopped,
    required super.isActive,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as int,
      name: json['name'] as String,
      triggerTime: Duration(
        minutes: json['triggerTimeMinutes'] as int,
        seconds: json['triggerTimeSeconds'] as int,
      ),
      soundIndex: json['soundIndex'] as int,
      cycleMultiplier: json['cycleMultiplier'] as int?,
      playUntilStopped: json['playUntilStopped'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'triggerTimeMinutes': triggerTime.inMinutes,
      'triggerTimeSeconds': triggerTime.inSeconds % 60,
      'soundIndex': soundIndex,
      'cycleMultiplier': cycleMultiplier,
      'playUntilStopped': playUntilStopped,
      'isActive': isActive,
    };
  }

  factory ProfileModel.defaultProfile(int id) {
    return ProfileModel(
      id: id,
      name: '${AppConstants.defaultProfileNamePrefix} $id',
      triggerTime: AppConstants.defaultTriggerTime,
      soundIndex: AppConstants.defaultSoundIndex,
      cycleMultiplier: AppConstants.defaultCycleMultiplier,
      playUntilStopped: false,
      isActive: id == 1, // First profile is active by default
    );
  }

  @override
  ProfileModel copyWith({
    int? id,
    String? name,
    Duration? triggerTime,
    int? soundIndex,
    int? cycleMultiplier,
    bool? playUntilStopped,
    bool? isActive,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      triggerTime: triggerTime ?? this.triggerTime,
      soundIndex: soundIndex ?? this.soundIndex,
      cycleMultiplier: cycleMultiplier ?? this.cycleMultiplier,
      playUntilStopped: playUntilStopped ?? this.playUntilStopped,
      isActive: isActive ?? this.isActive,
    );
  }
}

