import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'shell.dart';
import 'state/app_state.dart';
import 'theme/tokens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
  ));
  runApp(const AmpireApp());
}

class AmpireApp extends StatefulWidget {
  const AmpireApp({super.key});

  @override
  State<AmpireApp> createState() => _AmpireAppState();
}

class _AmpireAppState extends State<AmpireApp> {
  final AppState _state = AppState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ampire',
        theme: buildTheme(),
        home: const Shell(),
      ),
    );
  }
}
