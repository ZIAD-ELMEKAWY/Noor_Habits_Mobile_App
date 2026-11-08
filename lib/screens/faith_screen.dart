import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class FaithScreen extends StatefulWidget {
  const FaithScreen({super.key});
  @override
  State<FaithScreen> createState() => _FaithScreenState();
}

class _FaithScreenState extends State<FaithScreen> {
  final _dhikrs = ['سبحان الله', 'الحمد لله', 'الله أكبر',
                   'لا إله إلا الله', 'أستغفر الله', 'اللهم صلِّ على محمد'];
  String _dhikr = 'سبحان الله';
  int _count = 0;
  final _pagesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _count = Storage.today().dhikr['tap'] ?? 0;
  }

  Future<void> _tap() async {
    setState(() => _count++);
    final log = Storage.today();
    log.dhikr['tap'] = _count;
    await Storage.saveToday(log);
    if (_count % 33 == 0) {
      Vibration.vibrate(duration: 400); // long haptic every 33
    } else {
      Vibration.vibrate(duration: 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    final log = Storage.today();
    final goal = Storage.quranGoal;
    final quranPct = (log.quranPages / goal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: const Text('المنبه الذكي وإعدادات الأذان'),
          automaticallyImplyLeading: false),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // Tasbeeh tap counter
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              DropdownButton<String>(
                value: _dhikr, isExpanded: true,
                items: _dhikrs.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) => setState(() { _dhikr = v!; _count = 0; }),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _tap,
                child: Container(
                  width: 200, height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.emerald.withOpacity(.1),
                    border: Border.all(color: AppTheme.emerald, width: 6),
                  ),
                  child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('$_count',
                        style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w800,
                            color: AppTheme.emerald)),
                    const Text('اضغط في أي مكان', style: TextStyle(color: Colors.grey)),
                  ])),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        // Quran wird
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('ورد القرآن اليومي',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 8),
              Text('توقفت عند الصفحة ${Storage.quranLastPage}'),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: quranPct,
                  backgroundColor: Colors.grey.shade300, minHeight: 10),
              Text('${log.quranPages} / $goal صفحة'),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _pagesCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'أدخل عدد الصفحات', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () async {
                    final n = int.tryParse(_pagesCtrl.text);
                    if (n == null) return;
                    final l = Storage.today();
                    l.quranPages += n;
                    await Storage.saveToday(l);
                    await Storage.setQuranPage(Storage.quranLastPage + n);
                    _pagesCtrl.clear();
                    setState(() {});
                  },
                  child: const Text('تسجيل'),
                ),
              ]),
            ]),
          ),
        ),
      ]),
    );
  }
}
