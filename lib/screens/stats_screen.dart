import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  double _dayPct(DateTime d) {
    final log = Storage.forDate(d);
    final total = Storage.prayers.length + Storage.getHabits().length + 3;
    if (total == 0) return 0;
    int done = log.habits.values.where((v) => v).length;
    if ((log.dhikr['morning'] ?? 0) > 0) done++;
    if ((log.dhikr['evening'] ?? 0) > 0) done++;
    if (log.quranPages > 0) done++;
    return done / total * 100;
  }

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (i) => DateTime.now().subtract(Duration(days: 6 - i)));
    final pct = days.map(_dayPct).toList();

    // Category breakdown (today)
    final log = Storage.today();
    final prayerPct = Storage.prayers
        .map((p) => log.habits['p_$p'] == true).fold<double>(0, (a, e) => a + (e ? 1 : 0)) /
        Storage.prayers.length;
    final quranPct = (log.quranPages / Storage.quranGoal).clamp(0.0, 1.0);
    final habitPct = () {
      final hs = Storage.getHabits();
      if (hs.isEmpty) return 0.0;
      return hs.map((h) => log.habits[h.id] == true).fold<double>(0, (a, e) => a + (e ? 1 : 0)) / hs.length;
    }();

    return ListView(padding: const EdgeInsets.all(16), children: [
      Center(child: StreakChip(days: Storage.streak)),
      const SizedBox(height: 20),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('الأسبوع الحالي (%)',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: BarChart(BarChartData(
                barGroups: [
                  for (var i = 0; i < 7; i++)
                    BarChartGroupData(x: i, barRods: [
                      BarChartRodData(toY: pct[i], color: AppTheme.emerald,
                          width: 18, borderRadius: BorderRadius.circular(6)),
                    ]),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) => Text(
                        DateFormat('E', 'ar').format(days[v.toInt()]),
                        style: const TextStyle(fontSize: 10)),
                  )),
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                ),
                borderData: FlBorderData(show: false),
              )),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('إنجاز الفئات (اليوم)',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 12),
            for (final e in [('الصلوات', prayerPct, AppTheme.emerald),
                             ('ورد القرآن', quranPct, AppTheme.gold),
                             ('العادات', habitPct, AppTheme.sage)])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${e.$1} — ${(e.$2 * 100).round()}%'),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(value: e.$2, color: e.$3,
                      backgroundColor: Colors.grey.shade300, minHeight: 8),
                ]),
              ),
          ]),
        ),
      ),
    ]);
  }
}
