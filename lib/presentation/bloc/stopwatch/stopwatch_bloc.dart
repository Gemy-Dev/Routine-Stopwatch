import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/timer_service.dart';
import '../../services/background_service.dart';
import '../alarm/alarm_bloc.dart';
import '../alarm/alarm_event.dart';
import '../../../domain/entities/profile.dart';
import 'stopwatch_event.dart';
import 'stopwatch_state.dart';

class StopwatchBloc extends Bloc<StopwatchEvent, StopwatchState> {
  final TimerService _timerService;
  final BackgroundService _backgroundService;
  final AlarmBloc _alarmBloc;
  StreamSubscription<Duration>? _timerSubscription;
  Profile? _activeProfile;
  bool _alarmTriggered = false;

  StopwatchBloc({
    required TimerService timerService,
    required BackgroundService backgroundService,
    required AlarmBloc alarmBloc,
  })  : _timerService = timerService,
        _backgroundService = backgroundService,
        _alarmBloc = alarmBloc,
        super(const StopwatchInitial()) {
    on<StartTimer>(_onStartTimer);
    on<PauseTimer>(_onPauseTimer);
    on<ResetTimer>(_onResetTimer);
    on<TimerTick>(_onTimerTick);

    _timerSubscription = _timerService.elapsedStream.listen((elapsed) {
      add(TimerTick(elapsed));
    });
    
    // Restore timer state on initialization
    _restoreTimerState();
  }

  Future<void> _restoreTimerState() async {
    // Check if timer was running when app was closed
    final wasRunning = await _timerService.wasRunning();
    
    if (wasRunning) {
      // Timer was running - restore it and continue
      // Start the timer service (it will restore from saved timestamp)
      await _timerService.start();
      
      // Restore foreground service if profile exists
      if (_activeProfile != null) {
        final elapsed = _timerService.elapsed;
        await _backgroundService.startForegroundService(
          elapsed: elapsed,
          profileName: _activeProfile!.name,
        );
      }
      
      // Trigger StartTimer event to properly restore the state
      add(const StartTimer());
    } else {
      final elapsed = _timerService.elapsed;
      if (elapsed != Duration.zero) {
        // Timer was paused, restore paused state
        _timerService.setElapsed(elapsed);
        add(TimerTick(elapsed));
      }
    }
  }

  void setActiveProfile(Profile profile) {
    _activeProfile = profile;
  }

  Future<void> _onStartTimer(
    StartTimer event,
    Emitter<StopwatchState> emit,
  ) async {
    _timerService.start();
    emit(StopwatchRunning(_timerService.elapsed));
    
    if (_activeProfile != null) {
      await _backgroundService.startForegroundService(
        elapsed: _timerService.elapsed,
        profileName: _activeProfile!.name,
      );
      
      // Schedule alarm notification for when trigger time is reached
      // Calculate when the alarm should trigger
      final now = DateTime.now();
      final triggerTime = now.add(_activeProfile!.triggerTime - _timerService.elapsed);
      
      // Only schedule if trigger time is in the future
      if (triggerTime.isAfter(now)) {
        await _backgroundService.scheduleAlarmNotification(
          profileName: _activeProfile!.name,
          soundIndex: _activeProfile!.soundIndex,
          triggerTime: triggerTime,
        );
      }
    }
  }

  Future<void> _onPauseTimer(
    PauseTimer event,
    Emitter<StopwatchState> emit,
  ) async {
    _timerService.pause();
    emit(StopwatchPaused(_timerService.elapsed));
    await _backgroundService.stopForegroundService();
    // Cancel scheduled alarm when paused
    await _backgroundService.cancelScheduledAlarm();
  }

  Future<void> _onResetTimer(
    ResetTimer event,
    Emitter<StopwatchState> emit,
  ) async {
    _timerService.reset();
    _alarmTriggered = false;
    emit(const StopwatchInitial());
    await _backgroundService.stopForegroundService();
    // Cancel scheduled alarm when reset
    await _backgroundService.cancelScheduledAlarm();
    _alarmBloc.add(const StopAlarm());
  }

  Future<void> _onTimerTick(
    TimerTick event,
    Emitter<StopwatchState> emit,
  ) async {
    if (state is StopwatchRunning) {
      emit(StopwatchRunning(event.elapsed));
      
      // Update notification
      if (_activeProfile != null) {
        await _backgroundService.updateNotification(
          elapsed: event.elapsed,
          profileName: _activeProfile!.name,
        );
      }

      // Check if trigger time is reached
      if (_activeProfile != null && !_alarmTriggered) {
        if (event.elapsed >= _activeProfile!.triggerTime) {
          _alarmTriggered = true;
          // Cancel scheduled notification since we're triggering manually
          await _backgroundService.cancelScheduledAlarm();
          // Set profile name in alarm bloc for notification
          _alarmBloc.setProfileName(_activeProfile!.name);
          _alarmBloc.add(StartAlarm(
            soundIndex: _activeProfile!.soundIndex,
            cycleMultiplier: _activeProfile!.cycleMultiplier,
            playUntilStopped: _activeProfile!.playUntilStopped,
          ));
        }
      }
    }
  }

  @override
  Future<void> close() {
    _timerSubscription?.cancel();
    _timerService.dispose();
    return super.close();
  }
}

