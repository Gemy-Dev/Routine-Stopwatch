import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/time_formatter.dart';
import '../../core/theme/app_theme.dart';

class StopwatchDisplay extends StatelessWidget {
  final Duration elapsed;

  const StopwatchDisplay({
    super.key,
    required this.elapsed,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate progress for circular indicator (assuming max 60 minutes)
    final maxDuration = const Duration(minutes: 60);
    final progress = elapsed.inSeconds / maxDuration.inSeconds;
    final clampedProgress = progress.clamp(0.0, 1.0);

    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circular progress indicator
          SizedBox(
            width: 280,
            height: 280,
            child: CircularProgressIndicator(
              value: clampedProgress,
              strokeWidth: 8,
              backgroundColor: AppTheme.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.lightBlueText,
              ),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Inner circle border
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
          ),
          // Timer text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                TimeFormatter.formatDuration(elapsed),
                style: const TextStyle(
                  color: AppTheme.white,
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 100,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.lightBlueText,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

