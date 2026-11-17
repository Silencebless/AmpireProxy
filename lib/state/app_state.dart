import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../models.dart';

enum ConnStatus { off, connecting, live }

enum Screen { home, servers, monitoring, tools, subscriptions, routing, log, about }

const List<String> routingNames = <String>[
  'Весь трафик',
  'Обход для РФ',
  'Выбранные приложения',
];

const List<String> routingHints = <String>[
  'Всё идёт через сервер',
  'Российские сайты напрямую, остальное через сервер',
  'Через сервер только отмеченные приложения',
];

const List<String> demoLog = <String>[
  'демо-журнал',
  '12:01:04  ядро запущено',
  '12:01:04  профиль загружен: 5 узлов',
  '12:01:05  выбран узел: Нидерланды, 38 мс',
  '12:01:05  туннель поднят',
];

/// Состояние приложения. В демо-режиме всё живёт в памяти, сеть не используется.
class AppState extends ChangeNotifier {
  final List<Subscription> subs = <Subscription>[];
  Subscription? active;
  ConnStatus status = ConnStatus.off;
  Screen screen = Screen.home;
  int seconds = 0;
  int routing = 1;
  bool split = false;
  bool kill = true;
  bool autoConnect = false;
  String? refreshNote;

  Timer? _tick;
  Timer? _connect;

  bool get live => status == ConnStatus.live;

  Screen? get backTarget => switch (screen) {
        Screen.servers => Screen.home,
        Screen.subscriptions || Screen.routing || Screen.log || Screen.about => Screen.tools,
        Screen.home || Screen.monitoring || Screen.tools => null,
      };

  int get tabIndex => switch (screen) {
        Screen.home || Screen.servers => 0,
        Screen.monitoring => 1,
        _ => 2,
      };

  double get downMbps => live ? 18 + 6 * math.sin(seconds / 3) : 0;
  double get upMbps => live ? 4 + 1.5 * math.cos(seconds / 4) : 0;

  String get clock {
    String two(int v) => v.toString().padLeft(2, '0');
    final h = seconds ~/ 3600;
    final m = (seconds ~/ 60) % 60;
    final s = seconds % 60;
    return '${two(h)}:${two(m)}:${two(s)}';
  }

  // ---------- навигация ----------

  void go(Screen s) {
    screen = s;
    notifyListeners();
  }

  void back() {
    final t = backTarget;
    if (t != null) go(t);
  }

  // ---------- подписки ----------

  void addDemoSubscription() {
    final n = subs.length;
    final sub = Subscription(
      name: n == 0 ? 'Демо-подписка' : 'Подписка ${n + 1}',
      nodes: demoNodeSets[n % demoNodeSets.length],
    );
    subs.add(sub);
    active = sub;
    notifyListeners();
    _reconnectIfLive();
  }

  void selectSubscription(Subscription s) {
    active = s;
    notifyListeners();
    _reconnectIfLive();
  }

  void selectNode(Subscription s, String nodeId) {
    s.selectedId = nodeId;
    active = s;
    screen = Screen.home;
    notifyListeners();
    _reconnectIfLive();
  }

  void deleteActive() {
    final a = active;
    if (a == null) return;
    subs.remove(a);
    active = subs.isEmpty ? null : subs.first;
    if (active == null) _setOff();
    notifyListeners();
  }

  void refresh() {
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    refreshNote = 'Обновлено ${two(now.hour)}:${two(now.minute)}';
    notifyListeners();
  }

  // ---------- настройки ----------

  void setRouting(int i) {
    routing = i;
    notifyListeners();
  }

  void setSplit(bool v) {
    split = v;
    notifyListeners();
  }

  void setKill(bool v) {
    kill = v;
    notifyListeners();
  }

  void setAutoConnect(bool v) {
    autoConnect = v;
    notifyListeners();
  }

  // ---------- подключение (имитация) ----------

  void toggle() {
    if (active == null) return;
    if (status == ConnStatus.connecting) return;
    if (status == ConnStatus.live) {
      _setOff();
      notifyListeners();
      return;
    }
    _beginConnect(const Duration(milliseconds: 1100));
  }

  void _beginConnect(Duration delay) {
    status = ConnStatus.connecting;
    _connect?.cancel();
    notifyListeners();
    _connect = Timer(delay, () {
      status = ConnStatus.live;
      seconds = 0;
      _tick?.cancel();
      _tick = Timer.periodic(const Duration(seconds: 1), (_) {
        seconds++;
        notifyListeners();
      });
      notifyListeners();
    });
  }

  void _reconnectIfLive() {
    if (status != ConnStatus.live) return;
    _tick?.cancel();
    _beginConnect(const Duration(milliseconds: 900));
  }

  void _setOff() {
    _connect?.cancel();
    _tick?.cancel();
    status = ConnStatus.off;
    seconds = 0;
  }

  @override
  void dispose() {
    _connect?.cancel();
    _tick?.cancel();
    super.dispose();
  }
}

/// Доступ к состоянию из любого виджета: AppScope.of(context).
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope не найден в дереве виджетов');
    return scope!.notifier!;
  }
}
