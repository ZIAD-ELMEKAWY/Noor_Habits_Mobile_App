import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../theme/app_theme.dart';

/// Circular progress ring (pure CustomPainter — no package needed)
class ProgressRing extends StatelessWidget {
  final double value; // 0..1
  final double size;
  final String centerText;
  final String? subText;
  const ProgressRing({
    super.key, required this.value, this.size = 150,
    this.centerText = '', this.subText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: CustomPaint(
        painter: _RingPainter(value),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(centerText,
                style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.emerald)),
            if (subText != null)
              Text(subText!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ]),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double v;
  _RingPainter(this.v);
  @override
  void paint(Canvas c, Size s) {
    final center = s.center(Offset.zero);
    final r = (s.shortestSide - 14) / 2;
    final bg = Paint()
      ..color = Colors.grey.withOpacity(.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    c.drawCircle(center, r, bg);
    final fg = Paint()
      ..color = AppTheme.emerald
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    c.drawArc(Rect.fromCircle(center: center, radius: r), -3.14159 / 2,
        6.28318 * v.clamp(0, 1), false, fg);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.v != v;
}

/// Circular habit checkbox
class CircleCheck extends StatelessWidget {
  final bool done;
  final Color color;
  final VoidCallback onTap;
  const CircleCheck({super.key, required this.done, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () { Vibration.vibrate(duration: 25); onTap(); },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 26, height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? color : Colors.transparent,
            border: Border.all(color: color, width: 2),
          ),
          child: done ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
        ),
      );
}

/// Fire streak chip
class StreakChip extends StatelessWidget {
  final int days;
  const StreakChip({super.key, required this.days});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.gold.withOpacity(.15),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('🔥', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 6),
          Text('$days يوماً من الالتزام!',
              style: const TextStyle(
                  color: AppTheme.gold, fontWeight: FontWeight.w700)),
        ]),
      );
}

const kMotivationalQuotes = [
  'أحب الأعمال إلى الله أدومها وإن قلّ',
  'العادات الصغيرة تصنع الفارق الكبير',
  'كن lights في كل يوم', // placeholder, replace as needed
  'استمر… فالمثابرة سر النجاح',
];
