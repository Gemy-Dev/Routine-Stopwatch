import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Color palette from the design
  static const Color skyBlue = Color(0xFF87CEEB); // Bright sky blue
  static const Color limeGreen = Color(0xFF32CD32); // Vibrant lime green
  static const Color lightBlue = Color(0xFFADD8E6); // Light blue for buttons
  static const Color brightGreen = Color(0xFF00FF00); // Bright green for START
  static const Color darkGrey = Color(0xFF424242); // Dark grey for STOP
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightBlueText = Color(0xFFB0E0E6); // Light blue for text
  static const Color lightGrey = Color(0xFFF5F5F5);
  // Gradient colors
  static  LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [skyBlue.withValues(alpha: 0.5), white.withValues(alpha: 0.5)],
  );

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: skyBlue.withValues(alpha: 0.5),
      brightness: Brightness.light,
      primary: skyBlue.withValues(alpha: 0.5),
      secondary: limeGreen.withValues(alpha: 0.5),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: skyBlue,
      
      // Material 3 App Bar
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        iconTheme: const IconThemeData(
          color: white,
          size: 24,
        ),
      ),

      // Material 3 Typography
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: white,
          fontSize: 72,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          color: white,
          fontSize: 48,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          color: lightBlueText,
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          color: lightBlueText,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        bodyLarge: TextStyle(
          color: white,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        labelLarge: TextStyle(
          color: white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),

      // Material 3 Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        color: Colors.white.withOpacity(0.1),
        surfaceTintColor: Colors.transparent,
      ),

      // Material 3 Filled Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
      ),

      // Material 3 Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 1,
        ),
      ),

      // Material 3 Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Material 3 Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,

        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
                   borderSide: BorderSide(color: limeGreen, width: 1),

        ),
      ),

      // Material 3 Dialog Theme
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        elevation: 6,
      ),
    );
  }

  // Material 3 Filled Button style for START button (bright green)
  static ButtonStyle get startButtonStyle => FilledButton.styleFrom(
        backgroundColor: brightGreen,
        foregroundColor: white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        minimumSize: const Size(120, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        elevation: 0,
      );

  // Material 3 Filled Button style for LAP/PAUSE button (light blue)
  static ButtonStyle get lapButtonStyle => FilledButton.styleFrom(
        backgroundColor: lightBlue,
        foregroundColor: white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        minimumSize: const Size(120, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        elevation: 0,
      );

  // Material 3 Filled Button style for STOP/RESET button (dark grey)
  static ButtonStyle get stopButtonStyle => FilledButton.styleFrom(
        backgroundColor: darkGrey,
        foregroundColor: white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        minimumSize: const Size(120, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        elevation: 0,
      );
}

