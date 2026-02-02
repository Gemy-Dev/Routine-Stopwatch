import 'package:equatable/equatable.dart';

abstract class AlarmEvent extends Equatable {
  const AlarmEvent();

  @override
  List<Object?> get props => [];
}

class StartAlarm extends AlarmEvent {
  final int soundIndex;
  final int? cycleMultiplier;
  final bool playUntilStopped;
  
  const StartAlarm({
    required this.soundIndex,
    this.cycleMultiplier,
    required this.playUntilStopped,
  });
  
  @override
  List<Object?> get props => [soundIndex, cycleMultiplier, playUntilStopped];
}

class StopAlarm extends AlarmEvent {
  const StopAlarm();
}

