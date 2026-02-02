import 'package:equatable/equatable.dart';

abstract class StopwatchEvent extends Equatable {
  const StopwatchEvent();

  @override
  List<Object?> get props => [];
}

class StartTimer extends StopwatchEvent {
  const StartTimer();
}

class PauseTimer extends StopwatchEvent {
  const PauseTimer();
}

class ResetTimer extends StopwatchEvent {
  const ResetTimer();
}

class TimerTick extends StopwatchEvent {
  final Duration elapsed;
  
  const TimerTick(this.elapsed);
  
  @override
  List<Object?> get props => [elapsed];
}

