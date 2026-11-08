import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'puzzle_challenge_screen.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});
  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen>
    with SingleTickerProviderStateMixin {
  late final _tab = TabController(length: 2, vsync: this);
  int _preReminder = 10;
  String _fajrFile = 'Default';
  final _alarms = <SmartAlarm>[];

  static const _puzzleNames = {PuzzleType.math: '➕ مسألة حسابية',
    PuzzleType.sorter: '🧩 ترتيب أرقام', PuzzleType.taps: '🔴 نقص 15 مرة'};

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('المنبه الذكي وإعدادات الأذان'),
          bottom: TabBar(controller: _tab, tabs: const [
            Tab(text: 'إعدادات الأذان'), Tab(text: 'المنبه الذكي'),
          ]),
        ),
        body: TabBarView(controller: _tab, children: [_azanTab(), _smartTab()]),
      );

  // ---------- Tab A: Azan ----------
  Widget _azanTab() => ListView(padding: const EdgeInsets.all(16), children: [
        for (final p in Storage.prayers)
          Card(
            child: ListTile(
              leading: const Icon(Icons.mosque_outlined, color: AppTheme.emerald),
              title: Text('صلاة $p'),
              subtitle: Text(p == 'الفجر' ? _fajrFile : 'النغمة الافتراضية'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                if (p == 'الفجر')
                  TextButton(
                    onPressed: _pickAzanFile,
                    child: const Text('اختيار ملف'),
                  ),
                IconButton(
                  icon: const Icon(Icons.play_circle_outline),
                  onPressed: () {/* flutter_ringtone_player.play(fromAsset/file) */},
                ),
              ]),
            ),
          ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _pickAzanFile,
          icon: const Icon(Icons.upload_file),
          label: const Text('رفع ملف أذان من الجهاز'),
        ),
        const SizedBox(height: 20),
        const Text('التذكير المسبق',
            style: TextStyle(fontWeight: FontWeight.w700)),
        DropdownButton<int>(
          value: _preReminder,
          isExpanded: true,
          items: const [5, 10, 15]
              .map((m) => DropdownMenuItem(value: m, child: Text('قبل $m دقيقة')))
              .toList(),
          onChanged: (v) => setState(() => _preReminder = v!),
        ),
      ]);

  Future<void> _pickAzanFile() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (r != null && r.files.single.path != null) {
      setState(() => _fajrFile = r.files.single.name);
    }
  }

  // ---------- Tab B: Smart alarm ----------
  Widget _smartTab() => ListView(padding: const EdgeInsets.all(16), children: [
        ElevatedButton.icon(
          onPressed: _newAlarm,
          icon: const Icon(Icons.add_alarm),
          label: const Text('إنشاء منبه جديد'),
        ),
        const SizedBox(height: 12),
        for (final a in _alarms)
          Card(
            child: ListTile(
              leading: const Icon(Icons.alarm, color: AppTheme.emerald),
              title: Text(a.time.fmt()),
              subtitle: Text('${_puzzleNames[a.puzzle]} — ${a.hard ? 'صعب' : 'سهل'}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => setState(() => _alarms.remove(a)),
              ),
            ),
          ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const PuzzleChallengeScreen(
                  isTest: true, puzzle: PuzzleType.math, hard: false))),
          icon: const Icon(Icons.science_outlined),
          label: const Text('تجربة اللغز'),
        ),
      ]);

  Future<void> _newAlarm() async {
    final time = await showTimePicker(
        context: context, initialTime: const TimeOfDay(hour: 5, minute: 30));
    if (time == null) return;
    if (!mounted) return;
    var puzzle = PuzzleType.math;
    var hard = false;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setD) => AlertDialog(
            title: const Text('إعدادات اللغز'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButton<PuzzleType>(
                value: puzzle, isExpanded: true,
                items: _puzzleNames.entries
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (v) => setD(() => puzzle = v!),
              ),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('سهل')),
                  ButtonSegment(value: true, label: Text('صعب')),
                ],
                selected: {hard},
                onSelectionChanged: (s) => setD(() => hard = s.first),
              ),
            ]),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('حفظ'),
              ),
            ],
          )),
    );
    setState(() => _alarms.add(SmartAlarm(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        time: TimeOfDayCompat(time.hour, time.minute),
        puzzle: puzzle, hard: hard)));
  }
}
