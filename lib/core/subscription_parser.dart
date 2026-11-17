import 'link_parser.dart';
import 'proxy_node.dart';

/// Сведения о подписке из заголовков ответа сервера подписки.
class SubscriptionMeta {
  const SubscriptionMeta({
    this.title,
    this.updateIntervalHours,
    this.supportUrl,
    this.webPageUrl,
    this.announce,
    this.uploadBytes = 0,
    this.downloadBytes = 0,
    this.totalBytes = 0,
    this.expireAt,
  });

  final String? title;
  final int? updateIntervalHours;
  final String? supportUrl;
  final String? webPageUrl;
  final String? announce;
  final int uploadBytes;
  final int downloadBytes;

  /// 0, если лимита нет.
  final int totalBytes;
  final DateTime? expireAt;

  int get usedBytes => uploadBytes + downloadBytes;

  /// Сколько дней осталось, или null, если срока нет. Не меньше нуля.
  int? daysLeft(DateTime now) {
    final e = expireAt;
    if (e == null) return null;
    final d = e.difference(now).inHours / 24;
    return d <= 0 ? 0 : d.ceil();
  }
}

class ParsedSubscription {
  const ParsedSubscription({required this.nodes, required this.meta, this.skipped = 0});

  final List<ProxyNode> nodes;
  final SubscriptionMeta meta;

  /// Сколько ссылок не удалось разобрать.
  final int skipped;
}

String? _text(String? v) {
  if (v == null) return null;
  final t = v.trim();
  if (t.isEmpty) return null;
  if (t.toLowerCase().startsWith('base64:')) {
    try {
      return decodeBase64Loose(t.substring(7));
    } on FormatException {
      return null;
    }
  }
  return t;
}

/// Разбирает заголовки: subscription-userinfo, profile-title, profile-update-interval,
/// support-url, profile-web-page-url, announce. Имена заголовков без учёта регистра.
SubscriptionMeta parseSubscriptionHeaders(Map<String, String> headers) {
  final h = <String, String>{for (final e in headers.entries) e.key.toLowerCase(): e.value};
  var up = 0;
  var down = 0;
  var total = 0;
  DateTime? expire;
  final info = h['subscription-userinfo'];
  if (info != null) {
    for (final m in RegExp(r'(\w+)\s*=\s*(\d+)').allMatches(info)) {
      final v = int.tryParse(m.group(2)!) ?? 0;
      switch (m.group(1)!.toLowerCase()) {
        case 'upload':
          up = v;
        case 'download':
          down = v;
        case 'total':
          total = v;
        case 'expire':
          if (v > 0) expire = DateTime.fromMillisecondsSinceEpoch(v * 1000, isUtc: true);
      }
    }
  }
  return SubscriptionMeta(
    title: _text(h['profile-title']),
    updateIntervalHours: int.tryParse((h['profile-update-interval'] ?? '').trim()),
    supportUrl: _text(h['support-url']),
    webPageUrl: _text(h['profile-web-page-url']),
    announce: _text(h['announce']),
    uploadBytes: up,
    downloadBytes: down,
    totalBytes: total,
    expireAt: expire,
  );
}

/// Разбирает тело подписки: список ссылок открытым текстом или в base64.
/// Бросает FormatException, если формат не распознан или это JSON (его добавим позже).
ParsedSubscription parseSubscription(
  String body, {
  Map<String, String> headers = const <String, String>{},
}) {
  final text = body.trim();
  if (text.startsWith('{') || text.startsWith('[')) {
    throw const FormatException('JSON-подписки пока не поддерживаются');
  }
  var content = text;
  if (!text.contains('://')) {
    try {
      final d = decodeBase64Loose(text.replaceAll(RegExp(r'\s'), ''));
      if (d.contains('://')) content = d;
    } on FormatException {
      // не base64
    }
  }
  if (!content.contains('://')) throw const FormatException('Формат подписки не распознан');

  final nodes = <ProxyNode>[];
  final seen = <String>{};
  var skipped = 0;
  for (final raw in content.split(RegExp(r'\r?\n'))) {
    final line = raw.trim();
    if (line.isEmpty || !line.contains('://')) continue;
    final node = parseLink(line);
    if (node == null) {
      skipped++;
      continue;
    }
    if (seen.add('${node.protocol}|${node.server}|${node.port}|${node.name}')) nodes.add(node);
  }
  return ParsedSubscription(nodes: nodes, meta: parseSubscriptionHeaders(headers), skipped: skipped);
}
