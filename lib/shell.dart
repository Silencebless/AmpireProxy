import 'package:flutter/material.dart';

import 'screens/home.dart';
import 'screens/monitoring.dart';
import 'screens/servers.dart';
import 'screens/tools.dart';
import 'state/app_state.dart';
import 'theme/tokens.dart';
import 'widgets/tab_bar.dart';

/// Оболочка: фон, текущий экран и плавающая панель вкладок.
/// На широких экранах (десктоп) содержимое держится в колонке шириной до 480.
class Shell extends StatelessWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return PopScope(
      canPop: s.backTarget == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) s.back();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: DefaultTextStyle(
              style: Tokens.body,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const Positioned.fill(child: _Background()),
                  SafeArea(
                    bottom: false,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: KeyedSubtree(key: ValueKey<Screen>(s.screen), child: _body(s.screen)),
                    ),
                  ),
                  const FloatingTabBar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(Screen screen) => switch (screen) {
        Screen.home => const HomeScreen(),
        Screen.servers => const ServersScreen(),
        Screen.monitoring => const MonitoringScreen(),
        Screen.tools => const ToolsScreen(),
        Screen.subscriptions => const SubscriptionsScreen(),
        Screen.routing => const RoutingScreen(),
        Screen.log => const LogScreen(),
        Screen.about => const AboutScreen(),
      };
}

/// Градиент от тёмно-синего к чёрному и синее свечение при активном соединении.
class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    final live = AppScope.of(context).live;
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Tokens.bgTop, Tokens.bgMid, Tokens.bgBottom],
              stops: <double>[0, 0.55, 1],
            ),
          ),
        ),
        AnimatedOpacity(
          opacity: live ? 1 : 0,
          duration: const Duration(milliseconds: 900),
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.15),
                radius: 0.9,
                colors: <Color>[Color(0x523D8BFF), Color(0x003D8BFF)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
