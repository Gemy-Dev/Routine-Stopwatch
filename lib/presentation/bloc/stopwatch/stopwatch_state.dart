import 'package:equatable/equatable.dart';

sealed class StopwatchState extends Equatable {
  const StopwatchState();

  @override
  List<Object?> get props => [];
}

class StopwatchInitial extends StopwatchState {
  const StopwatchInitial();
}

class StopwatchRunning extends StopwatchState {
  final Duration elapsed;
  
  const StopwatchRunning(this.elapsed);
  
  @override
  List<Object?> get props => [elapsed];
}

class StopwatchPaused extends StopwatchState {
  final Duration elapsed;
  
  const StopwatchPaused(this.elapsed);
  
  @override
  List<Object?> get props => [elapsed];
}

