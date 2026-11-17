import 'package:flutter/material.dart';

import '../models.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/capsule.dart';
import '../widgets/common.dart';

/// Список нод. Если подписок несколько, сверху выпадающий список подписок.
class ServersScreen extends StatefulWidget {
  const ServersScreen({super.key});

  @override
  State<ServersScreen> createState() => _ServersScreenState();
}

class _ServersScreenState extends State<ServersScreen> {
  int _view = 0;
  bool _open = false;
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      final s = AppScope.of(context);
      final a = s.active;
      final i = a == null ? 0 : s.subs.indexOf(a);
      _view = i < 0 ? 0 : i;
      _init = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final subs = s.subs;
    if (subs.isEmpty) {
      return ListView(
        padding: screenPadding,
        children: const [
          BackCircle(),
          ScreenTitle('Серверы'),
          AddSubscriptionPill(),
        ],
      );
    }
    final idx = _view < 0 ? 0 : (_view >= subs.length ? subs.length - 1 : _view);
    final view = subs[idx];
    return ListView(
      padding: screenPadding,
      children: [
        const BackCircle(),
        const ScreenTitle('Серверы'),
        if (subs.length > 1)
          _SubDropdown(
            subs: subs,
            active: s.active,
            viewed: view,
            open: _open,
            onToggle: () => setState(() => _open = !_open),
            onPick: (i) => setState(() {
              _view = i;
              _open = false;
            }),
          ),
        for (final n in view.allNodes)
          _NodeRow(
            node: n,
            selected: identical(view, s.active) && view.selectedId == n.id,
            onTap: () => s.selectNode(view, n.id),
          ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 7,
      height: 7,
      child: DecoratedBox(decoration: BoxDecoration(color: Tokens.green, shape: BoxShape.circle)),
    );
  }
}

class _NodeRow extends StatelessWidget {
  const _NodeRow({required this.node, required this.selected, required this.onTap});

  final NodeInfo node;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Capsule(
        radius: 26,
        color: selected ? Tokens.glass : Colors.transparent,
        borderColor: Colors.transparent,
        padding: const EdgeInsets.all(12),
        onTap: onTap,
        child: Row(
          children: [
            CodeBadge(node.code),
            const SizedBox(width: 14),
            Expanded(child: Text(node.name, style: Tokens.body)),
            Text(
              node.ping > 0 ? '${node.ping} мс' : 'лучший',
              style: const TextStyle(fontSize: 13, color: Tokens.green, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubDropdown extends StatelessWidget {
  const _SubDropdown({
    required this.subs,
    required this.active,
    required this.viewed,
    required this.open,
    required this.onToggle,
    required this.onPick,
  });

  final List<Subscription> subs;
  final Subscription? active;
  final Subscription viewed;
  final bool open;
  final VoidCallback onToggle;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final viewIndex = subs.indexOf(viewed);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Capsule(
            radius: 26,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            onTap: onToggle,
            child: Row(
              children: [
                if (identical(viewed, active)) ...const [_Dot(), SizedBox(width: 10)],
                Expanded(child: Text(viewed.name, style: Tokens.body)),
                AnimatedRotation(
                  turns: open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down_rounded, color: Tokens.mute),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: open
                ? Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(maxHeight: 232),
                    decoration: BoxDecoration(
                      color: Tokens.glass,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: Tokens.edge),
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      children: [
                        for (var i = 0; i < subs.length; i++)
                          Capsule(
                            radius: 20,
                            color: i == viewIndex ? Tokens.tabActive : Colors.transparent,
                            borderColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            onTap: () => onPick(i),
                            child: Row(
                              children: [
                                if (identical(subs[i], active)) ...const [_Dot(), SizedBox(width: 10)],
                                Expanded(
                                  child: Text(
                                    subs[i].name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: i == viewIndex ? Tokens.blue : Tokens.text,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
