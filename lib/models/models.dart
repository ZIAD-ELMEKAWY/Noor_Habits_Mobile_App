import 'dart:convert';
import 'package:hive/hive.dart';

class Habit {
  final String id;
  String title;
  String emoji;
  int colorValue;
  List<int> daysOfWeek; // empty = daily, 1=Mon..7=Sun
  bool notify;
  String? remindTime; // "08:00"
  String? remindMsg;

  Habit({
    required this.id,
    required this.title,
    this.emoji = '🌱',
    this.colorValue = 0xFF1B7A5E,
    this.daysOfWeek = const [],
    this.notify = false,
    this.remindTime,
    this.remindMsg,
  });

  bool get isDaily => daysOfWeek.isEmpty;

  Map<String, dynamic> toJson() => {
        'id': id, 'title': title, 'emoji': emoji, 'color': colorValue,
        'days': daysOfWeek, 'notify': notify,
        'time': remindTime, 'msg': remindMsg,
      };

  factory Habit.fromJson(Map j) => Habit(
        id: j['id'], title: j['title'], emoji: j['emoji'],
        colorValue: j['color'],
        daysOfWeek: List<int>.from(j['days'] ?? []),
        notify: j['notify'] ?? false,
        remindTime: j['time'], remindMsg: j['msg'],
      );
}

enum PuzzleType { math, sorter, taps }

class SmartAlarm {
  String id;
  TimeOfDayCompat time;
  List<int> days;
  PuzzleType puzzle;
  bool hard;

  SmartAlarm({
    required this.id,
    required this.time,
    this.days = const [],
    this.puzzle = PuzzleType.math,
    this.hard = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id, 'h': time.hour, 'm': time.minute, 'days': days,
        'puzzle': puzzle.index, 'hard': hard,
      };

  factory SmartAlarm.fromJson(Map j) => SmartAlarm(
        id: j['id'],
        time: TimeOfDayCompat(j['h'], j['m']),
        days: List<int>.from(j['days'] ?? []),
        puzzle: PuzzleType.values[j['puzzle'] ?? 0],
        hard: j['hard'] ?? false,
      );
}

class TimeOfDayCompat {
  final int hour, minute;
  const TimeOfDayCompat(this.hour, this.minute);
  String fmt() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

/// Daily log: box 'logs', key = yyyy-MM-dd, value = json map
class DayLog {
  final Map<String, bool> habits; // habitId -> done
  final Map<String, int> dhikr;   // dhikrKey -> count
  int quranPages;

  DayLog({Map<String, bool>? h, Map<String, int>? d, this.quranPages = 0})
      : habits = h ?? {}, dhikr = d ?? {};

  Map<String, dynamic> toJson() =>
      {'habits': habits, 'dhikr': dhikr, 'quran': quranPages};

  factory DayLog.fromJson(Map j) => DayLog(
        h: Map<String, bool>.from(j['habits'] ?? {}),
        d: Map<String, int>.from(j['dhikr'] ?? {}),
        quranPages: j['quran'] ?? 0,
      );

  static String encode(DayLog l) => jsonEncode(l.toJson());
  static DayLog decode(String s) =>
      DayLog.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
