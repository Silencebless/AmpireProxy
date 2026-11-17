import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

class MonitoringScreen extends StatelessWidget {
  const MonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final sub = s.active;
    return ListView(
      padding: screenPadding,
      children: [
        const ScreenTitle('Мониторинг'),
        _Big(s.live ? s.clock : '—', 52),
        const _Cap('Время сеанса'),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Big(s.live ? s.downMbps.toStringAsFixed(1) : '—', 36),
                  const _Cap('Загрузка, Мбит/с'),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Big(s.live ? s.upMbps.toStringAsFixed(1) : '—', 36),
                  const _Cap('Отдача, Мбит/с'),
                ],
              ),
            ),
          ],
        ),
        if (sub != null) ...[
          const SizedBox(height: 8),
          _Cap(sub.name),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: sub.usedGb / sub.totalGb,
              minHeight: 8,
              backgroundColor: Tokens.glass,
              valueColor: const AlwaysStoppedAnimation<Color>(Tokens.blue),
            ),
          ),
          const SizedBox(height: 8),
          _Cap('${sub.usedGb} из ${sub.totalGb.toStringAsFixed(0)} ГБ, осталось ${sub.days} дн.'),
        ],
      ],
    );
  }
}

class _Big extends StatelessWidget {
  const _Big(this.text, this.size);

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: size, fontWeight: FontWeight.w300, color: Tokens.text, height: 1.1),
    );
  }
}

class _Cap extends StatelessWidget {
  const _Cap(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 18),
      child: Text(text, style: Tokens.caption),
    );
  }
}
