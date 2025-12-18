import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Tokyo'));

    // Android initialization
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  // Request permissions (Android 13+)
  Future<bool> requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    final iOS = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iOS != null) {
      final granted = await iOS.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  // Schedule a single notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pill_reminder_channel',
          'お薬リマインダー',
          channelDescription: 'お薬を飲む時間をお知らせします',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Schedule daily repeating notification
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pill_reminder_channel',
          'お薬リマインダー',
          channelDescription: 'お薬を飲む時間をお知らせします',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Daily repeat
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // Schedule multiple doses for a reminder
  Future<void> scheduleReminderDoses({
    required String reminderId,
    required String medicineName,
    required List<String> doseTimes, // ['08:00', '12:00', '18:00']
    required String repeatType,
  }) async {
    for (int i = 0; i < doseTimes.length; i++) {
      final time = doseTimes[i];
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // Create unique ID: reminderId + dose index
      final notificationId = '${reminderId}_$i'.hashCode;

      // Determine dose label
      String doseLabel = '';
      if (doseTimes.length == 2) {
        doseLabel = i == 0 ? '朝' : '夜';
      } else if (doseTimes.length == 3) {
        doseLabel = ['朝', '昼', '夜'][i];
      } else if (doseTimes.length == 4) {
        doseLabel = ['朝', '昼', '夕', '夜'][i];
      }

      final title =
          '$medicineName ${doseLabel.isNotEmpty ? "($doseLabel)" : ""}';
      final body = 'お薬の時間です - ${i + 1}回目';

      if (repeatType == 'everyday') {
        await scheduleDailyNotification(
          id: notificationId,
          title: title,
          body: body,
          hour: hour,
          minute: minute,
          payload: '$reminderId|$i',
        );
      } else {
        // For non-repeating, schedule once
        final scheduledTime = _nextInstanceOfTime(hour, minute).toLocal();
        await scheduleNotification(
          id: notificationId,
          title: title,
          body: body,
          scheduledTime: scheduledTime,
          payload: '$reminderId|$i',
        );
      }
    }
  }

  // Cancel specific dose notification
  Future<void> cancelDoseNotification(String reminderId, int doseIndex) async {
    final notificationId = '${reminderId}_$doseIndex'.hashCode;
    await _notifications.cancel(notificationId);
  }

  // Cancel all notifications for a reminder
  Future<void> cancelReminderNotifications(
      String reminderId, int dosesCount) async {
    for (int i = 0; i < dosesCount; i++) {
      await cancelDoseNotification(reminderId, i);
    }
  }

  // Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  // Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
