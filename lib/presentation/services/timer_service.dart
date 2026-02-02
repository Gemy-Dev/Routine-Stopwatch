import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class TimerService {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _isRunning = false;
  DateTime? _startTime;
  Duration _pausedElapsed = Duration.zero;
  
  final StreamController<Duration> _elapsedController = StreamController<Duration>.broadcast();
  Stream<Duration> get elapsedStream => _elapsedController.stream;
  
  Duration get elapsed {
    if (_isRunning && _startTime != null) {
      // Calculate elapsed time from start time (works even when app is backgrounded)
      return _pausedElapsed + DateTime.now().difference(_startTime!);
    }
    return _elapsed;
  }
  
  bool get isRunning => _isRunning;

  Future<void> start() async {
    if (_isRunning) return;
    
    // Load saved state if exists
    await _loadState();
    
    // If timer was running before app closed, restore from saved timestamp
    if (_startTime != null) {
      // Timer was running - continue from saved start time
      // Don't reset startTime, keep using the saved one
      _isRunning = true;
    } else {
      // Starting fresh
      _isRunning = true;
      _startTime = DateTime.now();
      _pausedElapsed = Duration.zero;
    }
    
    // Save state
    await _saveState();
    
    // Start the periodic timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      _elapsed = elapsed; // Use getter to calculate from start time
      _elapsedController.add(_elapsed);
      // Save state periodically to persist the running state
      await _saveState();
    });
    
    // Immediately emit current elapsed time
    _elapsed = elapsed;
    _elapsedController.add(_elapsed);
  }

  Future<void> pause() async {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    
    // Save paused elapsed time
    _pausedElapsed = elapsed;
    _elapsed = _pausedElapsed;
    _startTime = null;
    
    await _saveState();
    _elapsedController.add(_elapsed);
  }

  Future<void> reset() async {
    _timer?.cancel();
    _timer = null;
    _elapsed = Duration.zero;
    _pausedElapsed = Duration.zero;
    _isRunning = false;
    _startTime = null;
    
    await _clearState();
    _elapsedController.add(_elapsed);
  }

  void setElapsed(Duration duration) {
    _elapsed = duration;
    _pausedElapsed = duration;
    _elapsedController.add(_elapsed);
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    if (_isRunning && _startTime != null) {
      await prefs.setInt(AppConstants.stopwatchStateKey, 1); // 1 = running
      await prefs.setInt(AppConstants.stopwatchElapsedKey, _pausedElapsed.inSeconds);
      await prefs.setInt('stopwatch_start_timestamp', _startTime!.millisecondsSinceEpoch);
    } else if (!_isRunning && _elapsed != Duration.zero) {
      await prefs.setInt(AppConstants.stopwatchStateKey, 2); // 2 = paused
      await prefs.setInt(AppConstants.stopwatchElapsedKey, _elapsed.inSeconds);
    } else {
      await prefs.setInt(AppConstants.stopwatchStateKey, 0); // 0 = stopped
      await prefs.setInt(AppConstants.stopwatchElapsedKey, 0);
    }
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final state = prefs.getInt(AppConstants.stopwatchStateKey) ?? 0;
    final savedElapsed = prefs.getInt(AppConstants.stopwatchElapsedKey) ?? 0;
    final savedStartTimestamp = prefs.getInt('stopwatch_start_timestamp');
    
    if (state == 1 && savedStartTimestamp != null) {
      // Was running - restore from saved start time
      final savedStartTime = DateTime.fromMillisecondsSinceEpoch(savedStartTimestamp);
      _pausedElapsed = Duration(seconds: savedElapsed);
      _startTime = savedStartTime;
      // Calculate current elapsed time from the saved start timestamp
      _elapsed = _pausedElapsed + DateTime.now().difference(_startTime!);
      // Don't set _isRunning here - let start() method handle it
    } else if (state == 2) {
      // Was paused
      _pausedElapsed = Duration(seconds: savedElapsed);
      _elapsed = _pausedElapsed;
      _startTime = null;
      _isRunning = false;
    } else {
      _elapsed = Duration.zero;
      _pausedElapsed = Duration.zero;
      _startTime = null;
      _isRunning = false;
    }
  }
  
  // Method to check if timer was running when app was closed
  Future<bool> wasRunning() async {
    final prefs = await SharedPreferences.getInstance();
    final state = prefs.getInt(AppConstants.stopwatchStateKey) ?? 0;
    return state == 1;
  }

  Future<void> _clearState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.stopwatchStateKey);
    await prefs.remove(AppConstants.stopwatchElapsedKey);
    await prefs.remove('stopwatch_start_timestamp');
  }

  void dispose() {
    _timer?.cancel();
    _elapsedController.close();
  }
}

