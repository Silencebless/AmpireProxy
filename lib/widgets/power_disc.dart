import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/tokens.dart';

/// Большая круглая кнопка питания. Единственное «срежиссированное» движение:
/// при подключении кольцо загорается синим, пока соединение устанавливается, оно пульсирует.
class PowerDisc extends StatefulWidget {
  const PowerDisc({super.key, required this.status, required this.onTap});

  final ConnStatus status;
  final VoidCallback onTap;

  @override
  State<PowerDisc> createState() => _PowerDiscState();
}

class _PowerDiscState extends State<PowerDisc> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(PowerDisc oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.status == ConnStatus.connecting) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final live = widget.status == ConnStatus.live;
    final busy = widget.status == ConnStatus.connecting;
    return Semantics(
      button: true,
      label: 'Подключить или отключить',
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, _) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(end: live ? 1.0 : 0.0),
              duration: const Duration(milliseconds: 600),
              builder: (context, t, _) {
                final p = busy ? 0.35 + 0.3 * _pulse.value : 0.0;
                final level = t > p ? t : p;
                return Container(
                  width: 208,
                  height: 208,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Tokens.disc,
                    border: Border.all(color: Tokens.discEdge),
                    boxShadow: [
                      BoxShadow(
                        color: Tokens.blue.withAlpha((level * 255).round()),
                        spreadRadius: 3,
                      ),
                      BoxShadow(
                        color: Tokens.blue.withAlpha((level * 115).round()),
                        blurRadius: 64,
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: 58,
                    height: 58,
                    child: CustomPaint(
                      painter: _PowerGlyph(Color.lerp(Tokens.mute, Tokens.text, t) ?? Tokens.mute),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Тонкий значок питания (как в прототипе), нарисованный по сетке 24x24.
class _PowerGlyph extends CustomPainter {
  _PowerGlyph(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawLine(const Offset(12, 3), const Offset(12, 11), p);
    final arc = Path()
      ..moveTo(6.3, 6.8)
      ..arcToPoint(
        const Offset(17.7, 6.8),
        radius: const Radius.circular(8),
        largeArc: true,
        clockwise: false,
      );
    canvas.drawPath(arc, p);
  }

  @override
  bool shouldRepaint(_PowerGlyph oldDelegate) => oldDelegate.color != color;
}
