import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/injection/service_locator.dart' as di;
import 'core/theme/app_theme.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/bloc/stopwatch/stopwatch_bloc.dart';
import 'presentation/bloc/profile/profile_bloc.dart';
import 'presentation/bloc/profile/profile_event.dart';
import 'presentation/bloc/alarm/alarm_bloc.dart';
import 'presentation/services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await di.init();
  
  // Initialize background service
  final backgroundService = di.sl<BackgroundService>();
  await backgroundService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<StopwatchBloc>(),
        ),
        BlocProvider(
          create: (_) {
            final bloc = di.sl<ProfileBloc>();
            bloc.add(const LoadProfiles());
            return bloc;
          },
        ),
        BlocProvider(
          create: (_) => di.sl<AlarmBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Routine Stopwatch',
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
