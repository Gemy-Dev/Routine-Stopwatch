import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../bloc/alarm/alarm_bloc.dart';
import '../bloc/alarm/alarm_event.dart';
import '../injection/service_locator.dart' as di;

class BackgroundService {
  static const String notificationChannelId = 'stopwatch_channel';
  static const String alarmChannelId = 'alarm_channel';
  static const int notificationId = 1;
  static const int alarmNotificationId = 2;
  static const String dismissActionId = 'dismiss_action';
  static const String stopAlarmActionId = 'stop_alarm_action';

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize timezone data for scheduled notifications
    tz.initializeTimeZones();
    await _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTapped,
    );

    // Stopwatch channel
    const androidChannel = AndroidNotificationChannel(
      notificationChannelId,
      'Stopwatch Timer',
      description: 'Notifications for the stopwatch timer',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );

    // Alarm channel
    const androidAlarmChannel = AndroidNotificationChannel(
      alarmChannelId,
      'Alarm',
      description: 'Alarm notifications',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
    
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidAlarmChannel);
  }

  void _onNotificationTapped(NotificationResponse response) {
    _handleNotificationResponse(response);
  }

  // Background notification handler (runs in isolate)
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    // This runs in a background isolate, so we can't access GetIt
    // The notification will be handled when app opens
  }

  void _handleNotificationResponse(NotificationResponse response) {
    if (response.actionId == dismissActionId) {
      // Dismiss/hide the stopwatch notification
      stopForegroundService();
    } else if (response.actionId == stopAlarmActionId) {
      // Stop the alarm from action button
      _stopAlarm();
    } else if (response.id == alarmNotificationId && response.actionId == null) {
      // Alarm notification was tapped - start playing alarm if app is open
      _startAlarmFromNotification();
    }
  }

  void _stopAlarm() {
    try {
      final alarmBloc = di.sl.get<AlarmBloc>();
      alarmBloc.add(const StopAlarm());
      cancelScheduledAlarm();
    } catch (e) {
      print('Error stopping alarm: $e');
    }
  }

  void _startAlarmFromNotification() {
    // When alarm notification is tapped, the app will open
    // The alarm state will be restored when the app initializes
    // This is handled by checking if alarm was triggered in the timer service
  }

  Future<void> startForegroundService({
    required Duration elapsed,
    required String profileName,
  }) async {
    const dismissAction = AndroidNotificationAction(
      dismissActionId,
      'Hide',
      showsUserInterface: false,
    );

    const androidDetails = AndroidNotificationDetails(
      notificationChannelId,
      'Stopwatch Timer',
      channelDescription: 'Timer is running in the background',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      showWhen: false,
      autoCancel: false,
      actions: [dismissAction],
    );

    // Start foreground service on Android
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.startForegroundService(
          notificationId,
          'Stopwatch: $profileName',
          'Time: ${_formatDuration(elapsed)}',
          notificationDetails: androidDetails,
        );
  }

  Future<void> updateNotification({
    required Duration elapsed,
    required String profileName,
  }) async {
    const dismissAction = AndroidNotificationAction(
      dismissActionId,
      'Hide',
      showsUserInterface: false,
    );

    const androidDetails = AndroidNotificationDetails(
      notificationChannelId,
      'Stopwatch Timer',
      channelDescription: 'Timer is running in the background',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      showWhen: false,
      autoCancel: false,
      actions: [dismissAction],
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      notificationId,
      'Stopwatch: $profileName',
      'Time: ${_formatDuration(elapsed)}',
      notificationDetails,
    );
  }

  Future<void> showAlarmNotification({
    required String profileName,
    required int soundIndex,
  }) async {
    const stopAction = AndroidNotificationAction(
      stopAlarmActionId,
      'Stop Alarm',
      showsUserInterface: false,
    );

    const androidDetails = AndroidNotificationDetails(
      alarmChannelId,
      'Alarm',
      channelDescription: 'Alarm is playing',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      showWhen: true,
      autoCancel: false,
      actions: [stopAction],
      playSound: true,
      enableVibration: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      alarmNotificationId,
      'Alarm: $profileName',
      'Alarm is playing - Tap to stop',
      notificationDetails,
    );
  }

  Future<void> hideAlarmNotification() async {
    await _notifications.cancel(alarmNotificationId);
  }

  Future<void> stopForegroundService() async {
    await _notifications.cancel(notificationId);
  }

  /// Schedule an alarm notification that will trigger even when app is terminated
  Future<void> scheduleAlarmNotification({
    required String profileName,
    required int soundIndex,
    required DateTime triggerTime,
  }) async {
    // Cancel any existing scheduled alarm
    await cancelScheduledAlarm();

    const stopAction = AndroidNotificationAction(
      stopAlarmActionId,
      'Stop Alarm',
      showsUserInterface: false,
    );

    final androidDetails = AndroidNotificationDetails(
      alarmChannelId,
      'Alarm',
      channelDescription: 'Alarm notifications',
      importance: Importance.max,
      priority: Priority.max,
      ongoing: true,
      showWhen: true,
      autoCancel: false,
      actions: [stopAction],
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('notification'), // Use system sound as fallback
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    // Schedule the notification
    await _notifications.zonedSchedule(
      alarmNotificationId,
      'Alarm: $profileName',
      'Alarm triggered - Tap to stop',
      tz.TZDateTime.from(triggerTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancel the scheduled alarm notification
  Future<void> cancelScheduledAlarm() async {
    await _notifications.cancel(alarmNotificationId);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

