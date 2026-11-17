/// Нода (сервер) из подписки.
class NodeInfo {
  const NodeInfo(this.id, this.name, this.code, this.ping);

  final String id;
  final String name;
  final String code;

  /// Задержка в мс, 0 для «Авто».
  final int ping;
}

const NodeInfo autoNode = NodeInfo('auto', 'Авто', 'AU', 0);

/// Подписка со своим списком нод и выбранной нодой.
class Subscription {
  Subscription({
    required this.name,
    required this.nodes,
    this.usedGb = 18.4,
    this.totalGb = 100,
    this.days = 23,
  });

  final String name;
  final List<NodeInfo> nodes;
  double usedGb;
  double totalGb;
  int days;
  String selectedId = 'auto';

  List<NodeInfo> get allNodes => <NodeInfo>[autoNode, ...nodes];

  NodeInfo get selected =>
      allNodes.firstWhere((n) => n.id == selectedId, orElse: () => autoNode);
}

/// Встроенные демо-данные: наборы нод для первых подписок.
const List<List<NodeInfo>> demoNodeSets = <List<NodeInfo>>[
  <NodeInfo>[
    NodeInfo('nl', 'Нидерланды', 'NL', 38),
    NodeInfo('de', 'Германия', 'DE', 44),
    NodeInfo('fi', 'Финляндия', 'FI', 29),
    NodeInfo('kz', 'Казахстан', 'KZ', 61),
    NodeInfo('tr', 'Турция', 'TR', 72),
  ],
  <NodeInfo>[
    NodeInfo('se', 'Швеция', 'SE', 41),
    NodeInfo('pl', 'Польша', 'PL', 47),
    NodeInfo('us', 'США', 'US', 118),
    NodeInfo('jp', 'Япония', 'JP', 164),
    NodeInfo('am', 'Армения', 'AM', 58),
  ],
];
