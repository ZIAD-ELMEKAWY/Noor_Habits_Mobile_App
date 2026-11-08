import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class Notify {
  static final _fln = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _fln.initialize(const InitializationSettings(android: android));
    await _fln
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    tz.setLocalLocation(tz.getLocation('Asia/Riyadh')); // or device tz
  }

  static Future<void> scheduleDaily(int id, String title, String body,
      int hour, int minute) async {
    final now = tz.TZDateTime.now(tz.local);
    var t = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (t.isBefore(now)) t = t.add(const Duration(days: 1));
    await _fln.zonedSchedule(
      id, title, body, t,
      const NotificationDetails(
        android: AndroidNotificationDetails('habits', 'Habit Reminders',
            importance: Importance.high, channelDescription: 'Daily habit reminders'),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancel(int id) => _fln.cancel(id);
}
