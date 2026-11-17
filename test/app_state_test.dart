import 'package:ampire/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('у каждой подписки свой список нод и своя выбранная нода', () {
    final s = AppState();
    s.addDemoSubscription();
    s.addDemoSubscription();
    expect(s.subs.length, 2);
    expect(s.subs[0].nodes.first.id, 'nl');
    expect(s.subs[1].nodes.first.id, 'se');

    s.selectNode(s.subs[0], 'fi');
    expect(identical(s.active, s.subs[0]), isTrue);
    expect(s.subs[0].selected.id, 'fi');

    s.selectNode(s.subs[1], 'jp');
    expect(identical(s.active, s.subs[1]), isTrue);
    expect(s.subs[0].selected.id, 'fi');
    expect(s.subs[1].selected.id, 'jp');
    s.dispose();
  });

  test('удаление активной подписки переключает на первую оставшуюся', () {
    final s = AppState();
    s.addDemoSubscription();
    s.addDemoSubscription();
    s.deleteActive();
    expect(s.subs.length, 1);
    expect(identical(s.active, s.subs.first), isTrue);
    s.deleteActive();
    expect(s.active, isNull);
    s.dispose();
  });

  test('навигация: назад из вложенных экранов', () {
    final s = AppState();
    s.go(Screen.servers);
    expect(s.tabIndex, 0);
    s.back();
    expect(s.screen, Screen.home);
    s.go(Screen.routing);
    expect(s.tabIndex, 2);
    s.back();
    expect(s.screen, Screen.tools);
    s.back();
    expect(s.screen, Screen.tools);
    s.dispose();
  });

  test('без подписки подключиться нельзя', () {
    final s = AppState();
    s.toggle();
    expect(s.status, ConnStatus.off);
    s.dispose();
  });
}
