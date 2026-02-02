import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/profile.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/stopwatch/stopwatch_bloc.dart';
import '../bloc/stopwatch/stopwatch_event.dart';
import '../bloc/stopwatch/stopwatch_state.dart';
import '../bloc/profile/profile_bloc.dart';
import '../bloc/profile/profile_state.dart';
import '../bloc/alarm/alarm_bloc.dart';
import '../bloc/alarm/alarm_event.dart';
import '../bloc/alarm/alarm_state.dart';
import '../widgets/stopwatch_display.dart';
import '../widgets/alarm_stop_button.dart';
import 'settings_screen.dart';
import '../services/timer_service.dart';
import '../injection/service_locator.dart' as di;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Restore timer state when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreTimerState();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App came back to foreground - restore timer state
      _restoreTimerState();
    }
  }

  void _restoreTimerState() async {
    final timerService = di.sl<TimerService>();
    final stopwatchBloc = context.read<StopwatchBloc>();
    
    // Check if timer was running when app was closed
    final wasRunning = await timerService.wasRunning();
    
    if (wasRunning) {
      // Timer was running - the bloc will restore it
      // Just trigger a tick to update UI
      final elapsed = timerService.elapsed;
      stopwatchBloc.add(TimerTick(elapsed));
    } else {
      final elapsed = timerService.elapsed;
      if (elapsed != Duration.zero) {
        // Timer was paused - restore paused state
        stopwatchBloc.add(TimerTick(elapsed));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routine Stopwatch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.skyBlue.withOpacity(0.85),
              AppTheme.limeGreen.withOpacity(0.85),
            ],
          ),
        ),
        child: MultiBlocListener(
        listeners: [
          BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              Profile? activeProfile;
              if (state is ProfilesLoaded) {
                activeProfile = state.activeProfile;
              } else if (state is ProfileUpdated) {
                activeProfile = state.activeProfile;
              }
              
              if (activeProfile != null) {
                context.read<StopwatchBloc>().setActiveProfile(activeProfile);
              }
            },
          ),
        ],
        child: Column(
          children: [
            const SizedBox(height: 32),
            BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, profileState) {
                Profile? activeProfile;
                if (profileState is ProfilesLoaded) {
                  activeProfile = profileState.activeProfile;
                } else if (profileState is ProfileUpdated) {
                  activeProfile = profileState.activeProfile;
                }
                
                if (activeProfile != null) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: AppTheme.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      activeProfile.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.lightBlueText,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 32),
            BlocBuilder<StopwatchBloc, StopwatchState>(
              builder: (context, state) {
                Duration elapsed = Duration.zero;
                if (state is StopwatchRunning) {
                  elapsed = state.elapsed;
                } else if (state is StopwatchPaused) {
                  elapsed = state.elapsed;
                }
                return StopwatchDisplay(elapsed: elapsed);
              },
            ),
            const Spacer(),
            BlocBuilder<StopwatchBloc, StopwatchState>(
              builder: (context, state) {
                if (state is StopwatchRunning) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton(
                          onPressed: () {
                            context.read<StopwatchBloc>().add(const PauseTimer());
                          },
                          style: AppTheme.lapButtonStyle,
                          child: const Text(
                            'PAUSE',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        FilledButton(
                          onPressed: () {
                            context.read<StopwatchBloc>().add(const ResetTimer());
                          },
                          style: AppTheme.stopButtonStyle,
                          child: const Text(
                            'RESET',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is StopwatchPaused) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton(
                          onPressed: () {
                            context.read<StopwatchBloc>().add(const StartTimer());
                          },
                          style: AppTheme.startButtonStyle,
                          child: const Text(
                            'RESUME',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        FilledButton(
                          onPressed: () {
                            context.read<StopwatchBloc>().add(const ResetTimer());
                          },
                          style: AppTheme.stopButtonStyle,
                          child: const Text(
                            'RESET',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: FilledButton(
                      onPressed: () {
                        context.read<StopwatchBloc>().add(const StartTimer());
                      },
                      style: AppTheme.startButtonStyle.copyWith(
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                            horizontal: 56,
                            vertical: 24,
                          ),
                        ),
                      ),
                      child: const Text(
                        'START',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
            BlocBuilder<AlarmBloc, AlarmState>(
              builder: (context, state) {
                if (state is AlarmPlaying) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AlarmStopButton(
                      onPressed: () {
                        context.read<AlarmBloc>().add(const StopAlarm());
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
        ),
      ),
    );
  }
}

