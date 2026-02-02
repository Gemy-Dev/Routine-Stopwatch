class TimeFormatter {
  TimeFormatter._();

  /// Formats duration as MM:SS
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Parses MM:SS string to Duration
  static Duration? parseDuration(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return null;
      
      final minutes = int.parse(parts[0]);
      final seconds = int.parse(parts[1]);
      
      if (minutes < 0 || seconds < 0 || seconds >= 60) return null;
      
      return Duration(minutes: minutes, seconds: seconds);
    } catch (e) {
      return null;
    }
  }
}

