import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/sound_constants.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _cycleTimer;
  Timer? _durationTimer;
  bool _isPlaying = false;
  int _cyclesRemaining = 0;
  bool _playUntilStopped = false;
  String? _currentSoundPath;

  bool get isPlaying => _isPlaying;

  Future<void> playAlarm({
    required int soundIndex,
    required int? cycleMultiplier,
    required bool playUntilStopped,
  }) async {
    if (_isPlaying) {
      await stopAlarm();
    }

    _playUntilStopped = playUntilStopped;
    _currentSoundPath = SoundConstants.getSoundPath(soundIndex);
    
    if (playUntilStopped) {
      _cyclesRemaining = -1; // -1 means infinite
    } else {
      _cyclesRemaining = cycleMultiplier ?? 1;
    }

    _isPlaying = true;
    await _playCycle();
  }

  Future<void> _playCycle() async {
    if (!_isPlaying) return;

    try {
      final assetPath = _currentSoundPath!.replaceFirst('assets/', '');
      
      // Set player to release mode so we can control playback duration
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      
      // Start playing the sound
      try {
        await _audioPlayer.play(AssetSource(assetPath));
      } catch (e) {
        // If audio file is missing or invalid, use system beep as fallback
        // For now, we'll just continue with the timer cycle
        // In production, you should replace placeholder files with actual audio files
        print('Warning: Could not play audio file $assetPath: $e');
        // Continue with timer cycle even if audio fails
      }
      
      // Set a timer to stop after 30 seconds (one cycle)
      _cycleTimer?.cancel();
      _cycleTimer = Timer(const Duration(seconds: AppConstants.cycleDurationSeconds), () async {
        if (_isPlaying) {
          try {
            await _audioPlayer.stop();
          } catch (e) {
            // Ignore stop errors
          }
          
          // Check if we should continue
          if (_playUntilStopped) {
            // Infinite loop - play again
            _playCycle();
          } else {
            _cyclesRemaining--;
            if (_cyclesRemaining > 0) {
              // Play next cycle
              _playCycle();
            } else {
              // All cycles completed
              _isPlaying = false;
            }
          }
        }
      });
    } catch (e) {
      // If there's a critical error, stop playing
      _isPlaying = false;
      print('Error in audio playback: $e');
      // Don't rethrow to prevent app crash - just stop silently
    }
  }

  Future<void> stopAlarm() async {
    _isPlaying = false;
    _cyclesRemaining = 0;
    _cycleTimer?.cancel();
    _durationTimer?.cancel();
    try {
      await _audioPlayer.stop();
    } catch (e) {
      // Ignore errors when stopping
      print('Error stopping audio: $e');
    }
  }

  void dispose() {
    _cycleTimer?.cancel();
    _durationTimer?.cancel();
    _audioPlayer.dispose();
  }
}

