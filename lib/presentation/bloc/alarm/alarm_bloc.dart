import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/audio_service.dart';
import '../../services/background_service.dart';
import 'alarm_event.dart';
import 'alarm_state.dart';

class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
  final AudioService _audioService;
  final BackgroundService _backgroundService;
  String? _currentProfileName;

  AlarmBloc({
    required AudioService audioService,
    required BackgroundService backgroundService,
  })  : _audioService = audioService,
        _backgroundService = backgroundService,
        super(const AlarmIdle()) {
    on<StartAlarm>(_onStartAlarm);
    on<StopAlarm>(_onStopAlarm);
  }

  void setProfileName(String profileName) {
    _currentProfileName = profileName;
  }

  Future<void> _onStartAlarm(
    StartAlarm event,
    Emitter<AlarmState> emit,
  ) async {
    emit(const AlarmPlaying());
    
    // Show alarm notification
    await _backgroundService.showAlarmNotification(
      profileName: _currentProfileName ?? 'Unknown',
      soundIndex: event.soundIndex,
    );
    
    await _audioService.playAlarm(
      soundIndex: event.soundIndex,
      cycleMultiplier: event.cycleMultiplier,
      playUntilStopped: event.playUntilStopped,
    );
  }

  Future<void> _onStopAlarm(
    StopAlarm event,
    Emitter<AlarmState> emit,
  ) async {
    await _audioService.stopAlarm();
    await _backgroundService.hideAlarmNotification();
    emit(const AlarmStopped());
  }
}

