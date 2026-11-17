import 'package:ampire/main.dart';
import 'package:ampire/widgets/power_disc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('демо: добавить подписку, подключиться, отключиться', (tester) async {
    await tester.pumpWidget(const AmpireApp());
    expect(find.text('Ampire'), findsOneWidget);
    expect(find.text('Отключено'), findsOneWidget);
    expect(find.text('Сначала добавьте подписку'), findsOneWidget);

    await tester.tap(find.text('Добавьте подписку'));
    await tester.pumpAndSettle();
    expect(find.text('Добавить подписку'), findsOneWidget);

    await tester.tap(find.text('Из буфера'));
    await tester.pump();
    await tester.tap(find.text('Добавить'));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
    expect(find.text('Демо-подписка'), findsWidgets);
    expect(find.text('Авто'), findsOneWidget);

    await tester.tap(find.byType(PowerDisc));
    await tester.pump();
    expect(find.text('Подключение…'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.text('Подключено'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(find.textContaining('00:00:0'), findsOneWidget);

    await tester.tap(find.byType(PowerDisc));
    await tester.pumpAndSettle();
    expect(find.text('Отключено'), findsOneWidget);

    // Снимаем дерево, чтобы остановить таймеры состояния.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('нажатие на кнопку питания без подписки открывает шторку', (tester) async {
    await tester.pumpWidget(const AmpireApp());
    await tester.tap(find.byType(PowerDisc));
    await tester.pumpAndSettle();
    expect(find.text('Добавить подписку'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
