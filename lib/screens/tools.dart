import 'package:flutter/material.dart';

import '../models.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/capsule.dart';
import '../widgets/common.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return ListView(
      padding: screenPadding,
      children: [
        const ScreenTitle('Инструменты'),
        _ToolRow('Подписки', value: '${s.subs.length}', onTap: () => s.go(Screen.subscriptions)),
        _ToolRow('Маршрутизация', value: routingNames[s.routing], onTap: () => s.go(Screen.routing)),
        _SwitchRow('Раздельное туннелирование', s.split, s.setSplit),
        _SwitchRow('Kill switch', s.kill, s.setKill),
        _SwitchRow('Автоподключение', s.autoConnect, s.setAutoConnect),
        _ToolRow('Журнал', onTap: () => s.go(Screen.log)),
        _ToolRow('О приложении', onTap: () => s.go(Screen.about)),
        const Note('Демо-режим: настройки работают, туннель не создаётся.'),
      ],
    );
  }
}

class _ToolRow extends StatelessWidget {
  const _ToolRow(this.label, {this.value, required this.onTap});

  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Capsule(
        radius: 26,
        color: Colors.transparent,
        borderColor: Colors.transparent,
        minHeight: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        onTap: onTap,
        child: Row(
          children: [
            Expanded(child: Text(label, style: Tokens.body)),
            if (value != null)
              Flexible(
                child: Text(
                  value!,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Tokens.mute),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow(this.label, this.value, this.onChanged);

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Capsule(
        radius: 26,
        color: Colors.transparent,
        borderColor: Colors.transparent,
        minHeight: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        onTap: () => onChanged(!value),
        child: Row(
          children: [
            Expanded(child: Text(label, style: Tokens.body)),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: Tokens.blue,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Tokens.edge,
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ],
        ),
      ),
    );
  }
}

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return ListView(
      padding: screenPadding,
      children: [
        const BackCircle(),
        const ScreenTitle('Подписки'),
        for (var i = 0; i < s.subs.length; i++)
          _SubRow(index: i, sub: s.subs[i], active: identical(s.subs[i], s.active), onTap: () => s.selectSubscription(s.subs[i])),
        const AddSubscriptionPill(label: 'Добавить подписку', chevron: false),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: SoftButton('Обновить', s.refresh)),
            const SizedBox(width: 10),
            Expanded(child: SoftButton('Удалить активную', s.deleteActive)),
          ],
        ),
        if (s.refreshNote != null) Note(s.refreshNote!),
      ],
    );
  }
}

class _SubRow extends StatelessWidget {
  const _SubRow({required this.index, required this.sub, required this.active, required this.onTap});

  final int index;
  final Subscription sub;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Capsule(
        radius: 26,
        color: active ? Tokens.glass : Colors.transparent,
        borderColor: Colors.transparent,
        padding: const EdgeInsets.all(12),
        onTap: onTap,
        child: Row(
          children: [
            CodeBadge('${index + 1}'),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sub.name, style: Tokens.body),
                  Text('${sub.usedGb} из ${sub.totalGb.toStringAsFixed(0)} ГБ · ${sub.days} дн.', style: Tokens.caption),
                ],
              ),
            ),
            Text(
              active ? 'активна' : '',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Tokens.mute),
            ),
          ],
        ),
      ),
    );
  }
}

class RoutingScreen extends StatelessWidget {
  const RoutingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return ListView(
      padding: screenPadding,
      children: [
        const BackCircle(),
        const ScreenTitle('Маршрутизация'),
        for (var i = 0; i < routingNames.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Capsule(
              radius: 26,
              color: s.routing == i ? Tokens.glass : Colors.transparent,
              borderColor: Colors.transparent,
              padding: const EdgeInsets.all(14),
              onTap: () => s.setRouting(i),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(routingNames[i], style: Tokens.body),
                        Text(routingHints[i], style: Tokens.caption),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    s.routing == i ? 'выбрано' : '',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Tokens.mute),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: screenPadding,
      children: [
        const BackCircle(),
        const ScreenTitle('Журнал'),
        for (final line in demoLog)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            child: Text(
              line,
              style: const TextStyle(
                fontSize: 12,
                height: 1.6,
                color: Tokens.mute,
                fontFamily: 'monospace',
                fontFamilyFallback: <String>['Menlo', 'Consolas'],
              ),
            ),
          ),
      ],
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: screenPadding,
      children: const [
        BackCircle(),
        ScreenTitle('О приложении'),
        Note('Ampire — утилита для подключения к вашим серверам. Приложение ничего не продаёт и не предоставляет VPN-услуг, подписки в него только добавляются.'),
        Note('Оно не собирает данные о трафике и подключениях.'),
        Note('Версия 0.1, демо. Открытый код, лицензия GPL.'),
      ],
    );
  }
}
