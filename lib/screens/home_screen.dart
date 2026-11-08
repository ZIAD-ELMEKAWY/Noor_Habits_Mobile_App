import 'package:flutter/material.dart';
import 'package:hijri/hijri.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../widgets/common_widgets.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DayLog log = Storage.today();
  List<Habit> habits = [];

  @override
  void initState() {
    super.initState();
    habits = Storage.getHabits();
  }

  Future<void> _save() async {
    await Storage.saveToday(log);
    setState(() {});
  }

  double get _progress {
    final total = Storage.prayers.length + habits.length + 3; // prayers + habits + dhikr set + morning/evening + quran
    int done = 0;
    for (final p in Storage.prayers) { if (log.habits['p_$p'] == true) done++; }
    log.habits.forEach((k, v) { if (!k.startsWith('p_') && v) done++; });
    if ((log.dhikr['morning'] ?? 0) > 0) done++;
    if ((log.dhikr['evening'] ?? 0) > 0) done++;
    if (log.quranPages > 0) done++;
    return total == 0 ? 0 : done / total;
  }

  @override
  Widget build(BuildContext context) {
    final hijri = HijriCalendar.now();
    final now = DateTime.now();
    final quote = kMotivationalQuotes[now.day % kMotivationalQuotes.length];

    return RefreshIndicator(
      onRefresh: () async => setState(() {
        log = Storage.today();
        habits = Storage.getHabits();
      }),
      child: ListView(padding: const EdgeInsets.all(16), children: [
        // Header: dates + quote
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(DateFormat('EEEE، d MMMM yyyy', 'ar').format(now),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                Text('${hijri.hYear} هـ',
                    style: const TextStyle(color: AppTheme.emerald)),
              ]),
              const SizedBox(height: 8),
              const Row(children: [
                Icon(Icons.wb_sunny_outlined, size: 18, color: AppTheme.gold),
                SizedBox(width: 6),
                Text('22° ⛅ صافٍ جزئياً'),
              ]),
              const Divider(height: 20),
              Text('"$quote"', style: const TextStyle(fontStyle: FontStyle.italic)),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Center(child: ProgressRing(
          value: _progress,
          centerText: '${(_progress * 100).round()}%',
          subText: 'مُنجَز اليوم',
        )),
        const SizedBox(height: 24),
        // Islamic routine
        _sectionTitle('الروتين الإسلامي'),
        ...Storage.prayers.map((p) => Card(
          child: ListTile(
            leading: const Icon(Icons.mosque_outlined, color: AppTheme.emerald),
            title: Text('صلاة $p'),
            trailing: CircleCheck(
              done: log.habits['p_$p'] ?? false,
              color: AppTheme.emerald,
              onTap: () async {
                log.habits['p_$p'] = !(log.habits['p_$p'] ?? false);
                await _save();
              },
            ),
          ),
        )),
        Card(
          child: ListTile(
            leading: const Icon(Icons.wb_twilight, color: AppTheme.sage),
            title: const Text('أذكار الصباح والمساء'),
            subtitle: LinearProgressIndicator(
              value: ((log.dhikr['morning'] ?? 0) + (log.dhikr['evening'] ?? 0)) / 2,
              backgroundColor: Colors.grey.shade300,
            ),
            trailing: Text('${((log.dhikr['morning'] ?? 0) + (log.dhikr['evening'] ?? 0))}/2'),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(spacing: 10, runSpacing: 10, children: [
              for (final e in [('تسبيح', 'tasbeeh', '📿'), ('استغفار', 'istighfar', '🤲'),
                               ('صلاة على النبي', 'salawat', '💚')])
                _dhikrChip(e.$1, e.$2, e.$3),
            ]),
          ),
        ),
        // Quran wird
        Card(
          child: ListTile(
            leading: const Icon(Icons.menu_book, color: AppTheme.emerald),
            title: Text('ورد القرآن — تابع من صفحة ${Storage.quranLastPage}'),
            subtitle: Text('قرأت اليوم: ${log.quranPages} صفحة'),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle, color: AppTheme.emerald),
              onPressed: () async {
                log.quranPages++;
                await Storage.setQuranPage(Storage.quranLastPage + 1);
                await _save();
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Custom habits
        _sectionTitle('عاداتي'),
        if (habits.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('لا عادات بعد — اضغط + لإضافة عادة')),
          ),
        ...habits.map((h) => Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(h.colorValue).withOpacity(.15),
              child: Text(h.emoji, style: const TextStyle(fontSize: 20)),
            ),
            title: Text(h.title),
            subtitle: h.remindTime != null ? Text('⏰ ${h.remindTime}') : null,
            trailing: CircleCheck(
              done: log.habits[h.id] ?? false,
              color: Color(h.colorValue),
              onTap: () async {
                log.habits[h.id] = !(log.habits[h.id] ?? false);
                await _save();
              },
            ),
          ),
        )),
        const SizedBox(height: 80),
      ]),
    );
  }

  Widget _dhikrChip(String label, String key, String emoji) => ActionChip(
        avatar: Text(emoji),
        label: Text('$label: ${log.dhikr[key] ?? 0}'),
        onPressed: () async {
          log.dhikr[key] = (log.dhikr[key] ?? 0) + 1;
          await _save();
        },
      );

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      );
}
