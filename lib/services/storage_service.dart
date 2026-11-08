import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

class Storage {
  static late Box<String> habitsBox;
  static late Box<String> logsBox;
  static late Box settingsBox; // dynamic box

  static const prayers = ['الفجر', 'الظهر', 'العصر', 'المغرب', 'العشاء'];
  static const dhikrKeys = ['tasbeeh', 'istighfar', 'salawat', 'quran'];
  static const quranGoalKey = 'quranGoal';

  static Future<void> init() async {
    await Hive.initFlutter();
    habitsBox = await Hive.openBox<String>('habits');
    logsBox = await Hive.openBox<String>('logs');
    settingsBox = await Hive.openBox('settings');
  }

  static String todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  // ---------- Habits ----------
  static List<Habit> getHabits() =>
      habitsBox.values.map((s) => Habit.fromJson(Map<String, dynamic>.from(
          (Hive.box<String>('habits')) == null ? {} : _decode(s)))).toList();

  static Map _decode(String s) => Map<String, dynamic>.from(
      (const JsonCodec().decode(s) as Map).cast<String, dynamic>());

  static Future<void> saveHabit(Habit h) =>
      habitsBox.put(h.id, _Json.encode(h.toJson()));

  static Future<void> deleteHabit(String id) => habitsBox.delete(id);

  // ---------- Daily log ----------
  static DayLog today() {
    final raw = logsBox.get(todayKey());
    return raw == null ? DayLog() : DayLog.decode(raw);
  }

  static Future<void> saveToday(DayLog l) =>
      logsBox.put(todayKey(), DayLog.encode(l));

  static DayLog forDate(DateTime d) {
    final key =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final raw = logsBox.get(key);
    return raw == null ? DayLog() : DayLog.decode(raw);
  }

  // ---------- Quran ----------
  static int get quranLastPage => settingsBox.get('quranPage', defaultValue: 1);
  static Future<void> setQuranPage(int p) =>
      settingsBox.put('quranPage', p);
  static int get quranGoal =>
      settingsBox.get(quranGoalKey, defaultValue: 10);

  // ---------- Streak ----------
  static int get streak => settingsBox.get('streak', defaultValue: 0);
  static Future<void> bumpStreak() =>
      settingsBox.put('streak', streak + 1);
}

class _Json {
  static String encode(Map<String, dynamic> m) => _enc.convert(m);
  static const _enc = JsonCodec();
}
