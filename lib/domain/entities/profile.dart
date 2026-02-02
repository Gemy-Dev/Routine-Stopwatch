import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final int id;
  final String name;
  final Duration triggerTime;
  final int soundIndex; // 1-8
  final int? cycleMultiplier; // null if playUntilStopped is true
  final bool playUntilStopped;
  final bool isActive;

  const Profile({
    required this.id,
    required this.name,
    required this.triggerTime,
    required this.soundIndex,
    this.cycleMultiplier,
    required this.playUntilStopped,
    required this.isActive,
  });

  Profile copyWith({
    int? id,
    String? name,
    Duration? triggerTime,
    int? soundIndex,
    int? cycleMultiplier,
    bool? playUntilStopped,
    bool? isActive,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      triggerTime: triggerTime ?? this.triggerTime,
      soundIndex: soundIndex ?? this.soundIndex,
      cycleMultiplier: cycleMultiplier ?? this.cycleMultiplier,
      playUntilStopped: playUntilStopped ?? this.playUntilStopped,
      isActive: isActive ?? this.isActive,
    );
  }

  Duration get alarmDuration {
    if (playUntilStopped) {
      return const Duration(days: 1); // Effectively infinite
    }
    final multiplier = cycleMultiplier ?? 1;
    return Duration(seconds: multiplier * 30);
  }

  @override
  List<Object?> get props => [
        id,
        name,
        triggerTime,
        soundIndex,
        cycleMultiplier,
        playUntilStopped,
        isActive,
      ];
}

