import 'package:flutter/material.dart';

import '../models.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/add_sheet.dart';
import '../widgets/capsule.dart';
import '../widgets/common.dart';
import '../widgets/power_disc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<String> _names = <String>['Отключено', 'Подключение…', 'Подключено'];

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final sub = s.active;
    final String line;
    if (s.live) {
      line = '${sub?.selected.name ?? ''} · ${s.clock}';
    } else if (sub != null) {
      line = 'Нажмите, чтобы подключиться';
    } else {
      line = 'Сначала добавьте подписку';
    }
    return Padding(
      padding: screenPadding,
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_Logo(), _DemoChip()],
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PowerDisc(
                    status: s.status,
                    onTap: () {
                      if (sub == null) {
                        showAddSheet(context);
                      } else {
                        s.toggle();
                      }
                    },
                  ),
                  const SizedBox(height: 26),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 600),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      color: s.live ? Tokens.text : Tokens.mute,
                    ),
                    child: Text(_names[s.status.index]),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    line,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Tokens.mute),
                  ),
                ],
              ),
            ),
          ),
          if (sub == null) const AddSubscriptionPill() else _ServerPill(sub: sub),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 8,
          height: 8,
          child: DecoratedBox(decoration: BoxDecoration(color: Tokens.blue, shape: BoxShape.circle)),
        ),
        SizedBox(width: 8),
        Text('Ampire', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Tokens.text)),
      ],
    );
  }
}

class _DemoChip extends StatelessWidget {
  const _DemoChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Tokens.glass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Tokens.edge),
      ),
      child: const Text(
        'Демо-режим',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Tokens.mute),
      ),
    );
  }
}

/// Строка текущего сервера: по нажатию открывается список нод.
class _ServerPill extends StatelessWidget {
  const _ServerPill({required this.sub});

  final Subscription sub;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final node = sub.selected;
    final extra = s.subs.length > 1 ? ' · ${s.subs.indexOf(sub) + 1} из ${s.subs.length}' : '';
    return Capsule(
      minHeight: 64,
      padding: const EdgeInsets.fromLTRB(14, 0, 22, 0),
      onTap: () => s.go(Screen.servers),
      child: Row(
        children: [
          CodeBadge(node.code),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  node.name,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Tokens.text),
                ),
                Text('${sub.name}$extra', style: Tokens.caption),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Tokens.mute),
        ],
      ),
    );
  }
}
