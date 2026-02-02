import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/datasources/local_storage_datasource.dart';
import '../../../data/repositories/profile_repository_impl.dart';
import '../../../domain/repositories/profile_repository.dart';
import '../../../domain/usecases/get_profiles.dart';
import '../../../domain/usecases/save_profile.dart';
import '../../../domain/usecases/set_active_profile.dart';
import '../services/timer_service.dart';
import '../services/audio_service.dart';
import '../services/background_service.dart';
import '../bloc/stopwatch/stopwatch_bloc.dart';
import '../bloc/profile/profile_bloc.dart';
import '../bloc/alarm/alarm_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Data Sources
  sl.registerLazySingleton<LocalStorageDataSource>(
    () => LocalStorageDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetProfiles(sl()));
  sl.registerLazySingleton(() => SaveProfile(sl()));
  sl.registerLazySingleton(() => SetActiveProfile(sl()));

  // Services
  sl.registerLazySingleton(() => TimerService());
  sl.registerLazySingleton(() => AudioService());
  sl.registerLazySingleton(() => BackgroundService());

  // BLoCs - AlarmBloc is a singleton as it's shared
  sl.registerLazySingleton(() => AlarmBloc(
        audioService: sl(),
        backgroundService: sl(),
      ));
  
  sl.registerFactory(
    () => StopwatchBloc(
      timerService: sl(),
      backgroundService: sl(),
      alarmBloc: sl(),
    ),
  );
  sl.registerFactory(
    () => ProfileBloc(
      getProfiles: sl(),
      saveProfile: sl(),
      setActiveProfile: sl(),
    ),
  );
}

