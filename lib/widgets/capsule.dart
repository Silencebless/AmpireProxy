import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Базовая поверхность интерфейса: капсула или строка с нажатием.
class Capsule extends StatelessWidget {
  const Capsule({
    super.key,
    required this.child,
    this.onTap,
    this.radius = 32,
    this.color = Tokens.glass,
    this.borderColor = Tokens.edge,
    this.padding = EdgeInsets.zero,
    this.minHeight = 0,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double radius;
  final Color color;
  final Color borderColor;
  final EdgeInsetsGeometry padding;
  final double minHeight;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: borderColor),
    );
    Widget w = Material(
      color: color,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Padding(
            padding: padding,
            child: Align(alignment: Alignment.centerLeft, child: child),
          ),
        ),
      ),
    );
    if (semanticLabel != null) {
      w = Semantics(label: semanticLabel, button: onTap != null, child: w);
    }
    return w;
  }
}

/// Спокойная кнопка-капсула с подписью по центру.
class SoftButton extends StatelessWidget {
  const SoftButton(this.label, this.onTap, {super.key});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Capsule(
      radius: 26,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Center(child: Text(label, style: Tokens.body)),
    );
  }
}
