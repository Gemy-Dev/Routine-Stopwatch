import 'package:equatable/equatable.dart';

sealed class AlarmState extends Equatable {
  const AlarmState();

  @override
  List<Object?> get props => [];
}

class AlarmIdle extends AlarmState {
  const AlarmIdle();
}

class AlarmPlaying extends AlarmState {
  const AlarmPlaying();
}

class AlarmStopped extends AlarmState {
  const AlarmStopped();
}

