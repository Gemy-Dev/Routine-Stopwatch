class AppConstants {
  AppConstants._();

  static const int profileCount = 8;
  static const int cycleDurationSeconds = 30;
  static const String defaultProfileNamePrefix = 'Profile';
  static const int defaultSoundIndex = 1;
  static const int defaultCycleMultiplier = 1;
  static const Duration defaultTriggerTime = Duration(minutes: 4, seconds: 20);
  
  static const String profilesKey = 'profiles';
  static const String activeProfileIdKey = 'active_profile_id';
  static const String stopwatchStateKey = 'stopwatch_state';
  static const String stopwatchElapsedKey = 'stopwatch_elapsed';
}

