import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' show Time;
import '../models/models.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});
  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _title = TextEditingController();
  final _msg = TextEditingController();
  String _emoji = '🌱';
  int _color = 0xFF1B7A5E;
  int _freq = 0; // 0 daily, 1 specific, 2 weekly
  final Set<int> _days = {};
  bool _notify = false;
  TimeOfDayCompat _time = const TimeOfDayCompat(8, 0);

  static const _emojis = ['🌱', '📖', '🏃', '💧', '🧘', '📵', '🥗', '💤', '🚭', '📚'];
  static const _colors = [0xFF1B7A5E, 0xFF8FBCA6, 0xFFE8A33D, 0xFFD96C6C,
                          0xFF6C8CD9, 0xFFB46CD9, 0xFF4CAF50, 0xFF795548];
  static const _dayNames = ['سبت', 'أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة'];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          title: const Text('إضافة عادة جديدة'),
          actions: [TextButton(onPressed: _save, child: const Text('حفظ'))],
        ),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          TextField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'ما العادة التي تريد اكتسابها؟',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          const Text('اختر أيقونة', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            for (final e in _emojis)
              GestureDetector(
                onTap: () => setState(() => _emoji = e),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _emoji == e ? AppTheme.emerald.withOpacity(.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _emoji == e ? AppTheme.emerald : Colors.grey.shade300),
                  ),
                  child: Text(e, style: const TextStyle(fontSize: 24)),
                ),
              ),
          ]),
          const SizedBox(height: 20),
          const Text('اختر لوناً', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(children: [
            for (final c in _colors)
              GestureDetector(
                onTap: () => setState(() => _color = c),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Color(c),
                    border: _color == c ? Border.all(color: Colors.black, width: 3) : null,
                  ),
                  child: _color == c ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                ),
              ),
          ]),
          const SizedBox(height: 20),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('يومياً')),
              ButtonSegment(value: 1, label: Text('أيام محددة')),
              ButtonSegment(value: 2, label: Text('أسبوعياً')),
            ],
            selected: {_freq},
            onSelectionChanged: (s) => setState(() => _freq = s.first),
          ),
          if (_freq == 1 || _freq == 2) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 6, children: [
              for (var d = 1; d <= 7; d++)
                FilterChip(
                  label: Text(_dayNames[d % 7]),
                  selected: _days.contains(d),
                  onSelected: (v) => setState(() => v ? _days.add(d) : _days.remove(d)),
                ),
            ]),
          ],
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('التذكير'),
            subtitle: Text(_notify ? 'الوقت: ${_time.fmt()}' : 'إيقاف'),
            value: _notify,
            onChanged: (v) async {
              if (v) {
                final t = await showTimePicker(
                    context: context, initialTime: const TimeOfDay(hour: 8, minute: 0));
                if (t != null) setState(() => _time = TimeOfDayCompat(t.hour, t.minute));
              }
              setState(() => _notify = v);
            },
          ),
          if (_notify)
            TextField(
              controller: _msg,
              decoration: const InputDecoration(
                  labelText: 'رسالة التذكير', border: OutlineInputBorder()),
            ),
        ]),
      );

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) return;
    final h = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _title.text.trim(),
      emoji: _emoji, colorValue: _color,
      daysOfWeek: _days.toList()..sort(),
      notify: _notify, remindTime: _time.fmt(),
      remindMsg: _msg.text.isEmpty ? null : _msg.text,
    );
    await Storage.saveHabit(h);
    if (_notify) {
      await Notify.scheduleDaily(h.id.hashCode, h.title,
          h.remindMsg ?? 'حان وقت ${h.title}', _time.hour, _time.minute);
    }
    if (mounted) Navigator.pop(context);
  }
}
