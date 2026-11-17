import 'dart:ui';

import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/tokens.dart';

class _Tab {
  const _Tab(this.icon, this.label, this.screen, this.index);

  final IconData icon;
  final String label;
  final Screen screen;
  final int index;
}

const List<_Tab> _tabs = <_Tab>[
  _Tab(Icons.home_outlined, 'Главная', Screen.home, 0),
  _Tab(Icons.bar_chart_rounded, 'Мониторинг', Screen.monitoring, 1),
  _Tab(Icons.tune_rounded, 'Инструменты', Screen.tools, 2),
];

/// Плавающая панель вкладок из трёх пунктов. «Серверы» открываются со строки на главной.
class FloatingTabBar extends StatelessWidget {
  const FloatingTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final bottom = MediaQuery.of(context).padding.bottom;
    return Positioned(
      left: 12,
      right: 12,
      bottom: 12 + bottom,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xDB1C1D21),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: Tokens.edge),
            ),
            child: Row(
              children: [
                for (final t in _tabs)
                  _TabButton(
                    tab: t,
                    active: state.tabIndex == t.index,
                    onTap: () => state.go(t.screen),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.tab, required this.active, required this.onTap});

  final _Tab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? Tokens.blue : Tokens.text;
    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        label: tab.label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.fromLTRB(0, 9, 0, 8),
            decoration: BoxDecoration(
              color: active ? Tokens.tabActive : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tab.icon, size: 24, color: color),
                const SizedBox(height: 4),
                Text(
                  tab.label,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
