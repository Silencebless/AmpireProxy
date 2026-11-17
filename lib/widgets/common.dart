import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/tokens.dart';
import 'add_sheet.dart';
import 'capsule.dart';

/// Общие отступы экранов: снизу место под плавающую панель вкладок.
const EdgeInsets screenPadding = EdgeInsets.fromLTRB(20, 20, 20, 112);

/// Круг с кодом страны или номером.
class CodeBadge extends StatelessWidget {
  const CodeBadge(this.code, {super.key});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Tokens.glass,
        border: Border.all(color: Tokens.edge),
      ),
      child: Text(
        code,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Tokens.mute),
      ),
    );
  }
}

/// Круглая кнопка «назад» вверху вложенных экранов.
class BackCircle extends StatelessWidget {
  const BackCircle({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Capsule(
          radius: 22,
          onTap: state.back,
          semanticLabel: 'Назад',
          child: const Center(
            child: Icon(Icons.chevron_left_rounded, size: 28, color: Tokens.text),
          ),
        ),
      ),
    );
  }
}

class ScreenTitle extends StatelessWidget {
  const ScreenTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 6, 0, 18),
      child: Text(text, style: Tokens.title),
    );
  }
}

class Note extends StatelessWidget {
  const Note(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      child: Text(text, style: Tokens.caption),
    );
  }
}

/// Строка «Добавьте подписку» с синим плюсом.
class AddSubscriptionPill extends StatelessWidget {
  const AddSubscriptionPill({super.key, this.label = 'Добавьте подписку', this.chevron = true});

  final String label;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    return Capsule(
      minHeight: 64,
      padding: const EdgeInsets.fromLTRB(14, 0, 22, 0),
      onTap: () => showAddSheet(context),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Tokens.blue, shape: BoxShape.circle),
            child: const Text(
              '+',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Tokens.onBlue, height: 1),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Tokens.text),
            ),
          ),
          if (chevron) const Icon(Icons.chevron_right_rounded, color: Tokens.mute),
        ],
      ),
    );
  }
}
