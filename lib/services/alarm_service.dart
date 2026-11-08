import 'dart:isolate';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:vibration/vibration.dart';

/// Top-level entry point — must be a static/global function for the alarm isolate.
@pragma('vm:entry-point')
void alarmCallback() {
  // Keep ringing until the puzzle screen stops it.
  FlutterRingtonePlayer.playAlarm(volume: 1.0, looping: true, asAlarm: true);
  Vibration.vibrate(pattern: [0, 500, 250, 500], repeat: 0);
}

class AlarmService {
  static const _alarmId = 100;

  static Future<void> init() => AndroidAlarmManager.initialize();

  static Future<void> schedule(TimeOfDayCompat t, List<int> days) async {
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, now.day, t.hour, t.minute);
    if (next.isBefore(now)) next = next.add(const Duration(days: 1));
    await AndroidAlarmManager.oneShotAt(
      next, _alarmId, alarmCallback,
      exact: true, wakeup: true, rescheduleOnReboot: true,
    );
  }

  static Future<void> stop() async {
    await AndroidAlarmManager.cancel(_alarmId);
    await FlutterRingtonePlayer.stop();
    await Vibration.cancel();
  }
}
