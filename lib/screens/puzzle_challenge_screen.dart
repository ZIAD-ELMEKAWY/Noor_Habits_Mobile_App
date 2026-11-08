import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/alarm_service.dart';
import '../theme/app_theme.dart';

class PuzzleChallengeScreen extends StatefulWidget {
  final bool isTest;
  final PuzzleType puzzle;
  final bool hard;
  final String? alarmName;
  const PuzzleChallengeScreen({
    super.key, this.isTest = false, this.puzzle = PuzzleType.math,
    this.hard = false, this.alarmName,
  });
  @override
  State<PuzzleChallengeScreen> createState() => _PuzzleState();
}

class _PuzzleState extends State<PuzzleChallengeScreen> {
  late DateTime _now;
  Timer? _t;
  String _input = '';
  late int _a, _b, _answer;
  late List<int> _nums;
  int _taps = 0;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _t = Timer.periodic(const Duration(seconds: 1),
        (_) => setState(() => _now = DateTime.now()));
    _gen();
    // Disallow back-button dismissal during a real alarm
    if (!widget.isTest) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  void _gen() {
    final range = widget.hard ? 99 : 50;
    _a = 1 + _rng.nextInt(range);
    _b = 1 + _rng.nextInt(range);
    _answer = _a + _b;
    _nums = List.generate(4, (_) => _rng.nextInt(100))..sort();
    _taps = 0;
    _input = '';
  }

  @override
  void dispose() {
    _t?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _solve() async {
    bool ok = switch (widget.puzzle) {
      PuzzleType.math => int.tryParse(_input) == _answer,
      PuzzleType.sorter => _input == _nums.join(),
      PuzzleType.taps => _taps >= 15,
    };
    if (!ok) {
      HapticFeedback.vibrate();
      setState(() { _input = ''; _taps = 0; });
      return;
    }
    await AlarmService.stop();
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('🌅 صباح الخير!'),
          content: const Text('تم إيقاف المنبه بنجاح'),
          actions: [FilledButton(
              onPressed: () => Navigator.of(context)
                ..pop()..pop(), child: const Text('حسناً'))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => widget.isTest, // block back during real alarm
        child: Scaffold(
          backgroundColor: const Color(0xFF0E1B2C),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                const SizedBox(height: 20),
                Text(DateFormat('HH:mm').format(_now),
                    style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w800,
                        color: Colors.white)),
                Text(widget.alarmName ?? 'حان وقت الفجر والقيام',
                    style: const TextStyle(color: AppTheme.sage, fontSize: 16)),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.08),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(children: [
                    _puzzleBody(),
                    const SizedBox(height: 12),
                    Text(_input.isEmpty ? ' ' : _input,
                        style: const TextStyle(fontSize: 32, color: Colors.white)),
                  ]),
                ),
                const Spacer(),
                if (widget.puzzle != PuzzleType.taps) _numpad(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.emerald,
                        padding: const EdgeInsets.all(18)),
                    onPressed: _solve,
                    child: const Text('تأكيد الحل', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      );

  Widget _puzzleBody() => switch (widget.puzzle) {
        PuzzleType.math => Text('$_a + $_b = ?',
            style: const TextStyle(fontSize: 34, color: Colors.white,
                fontWeight: FontWeight.w700)),
        PuzzleType.sorter => Column(children: [
            const Text('رتّب الأرقام تصاعدياً', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (final n in _nums)
                Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('$n', style: const TextStyle(
                        fontSize: 28, color: Colors.white, fontWeight: FontWeight.w700))),
            ]),
          ]),
        PuzzleType.taps => GestureDetector(
            onTap: () { HapticFeedback.selectionClick(); setState(() => _taps++); },
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: Text('$_taps / 15',
                  style: const TextStyle(fontSize: 28, color: Colors.white,
                      fontWeight: FontWeight.w800)),
            ),
          ),
      };

  Widget _numpad() => GridView.count(
        shrinkWrap: true, crossAxisCount: 3,
        childAspectRatio: 2.2,
        children: [
          for (final k in ['1','2','3','4','5','6','7','8','9','⌫','0','✓'])
            TextButton(
              onPressed: () => setState(() {
                if (k == '⌫') { if (_input.isNotEmpty) _input = _input.substring(0, _input.length - 1); }
                else if (k == '✓') { _solve(); return; }
                else if (_input.length < 6) _input += k;
              }),
              child: Text(k, style: const TextStyle(fontSize: 24, color: Colors.white)),
            ),
        ],
      );
}
