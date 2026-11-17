import 'dart:convert';

import 'proxy_node.dart';

/// Base64 в любом алфавите (обычном и url-safe), в том числе без выравнивания.
String decodeBase64Loose(String input) {
  var s = input.trim().replaceAll('-', '+').replaceAll('_', '/');
  final pad = s.length % 4;
  if (pad == 2) {
    s += '==';
  } else if (pad == 3) {
    s += '=';
  } else if (pad == 1) {
    throw const FormatException('некорректный base64');
  }
  return utf8.decode(base64.decode(s));
}

String _decode(String s) {
  try {
    return Uri.decodeComponent(s);
  } catch (_) {
    return s;
  }
}

String? _nonEmpty(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();

bool _truthy(String? v) => v == '1' || (v != null && v.toLowerCase() == 'true');

List<String> _list(String? v) =>
    v == null ? const <String>[] : v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

String _network(String? t) {
  final v = (t ?? 'tcp').toLowerCase();
  if (v == 'h2') return 'http';
  return v.isEmpty ? 'tcp' : v;
}

class _Parts {
  const _Parts(this.base, this.name);

  final String base;
  final String name;
}

/// Отделяет название ноды (после #) от остальной ссылки.
_Parts _split(String link) {
  final i = link.indexOf('#');
  if (i < 0) return _Parts(link, '');
  return _Parts(link.substring(0, i), _decode(link.substring(i + 1)).trim());
}

class _HostPort {
  const _HostPort(this.host, this.port);

  final String host;
  final int port;
}

_HostPort _hostPort(String s) {
  final t = s.trim();
  if (t.startsWith('[')) {
    final e = t.indexOf(']');
    if (e < 0) throw const FormatException('адрес');
    return _HostPort(t.substring(1, e), int.parse(t.substring(e + 2)));
  }
  final c = t.lastIndexOf(':');
  if (c <= 0) throw const FormatException('адрес');
  return _HostPort(t.substring(0, c), int.parse(t.substring(c + 1)));
}

/// Разбирает одну ссылку. Возвращает null, если формат неизвестен или ссылка повреждена.
ProxyNode? parseLink(String raw) {
  final link = raw.trim();
  final i = link.indexOf('://');
  if (i <= 0) return null;
  final scheme = link.substring(0, i).toLowerCase();
  try {
    switch (scheme) {
      case 'vless':
        return _vless(link);
      case 'trojan':
        return _trojan(link);
      case 'vmess':
        return _vmess(link);
      case 'ss':
        return _shadowsocks(link);
      case 'hysteria2':
      case 'hy2':
        return _hysteria2(link);
      case 'tuic':
        return _tuic(link);
      default:
        return null;
    }
  } catch (_) {
    // Любая ошибка разбора (неверный адрес, порт, base64, JSON) означает «ссылка повреждена».
    return null;
  }
}

ProxyNode _vless(String link) {
  final parts = _split(link);
  final u = Uri.parse(parts.base);
  final q = u.queryParameters;
  if (u.host.isEmpty || !u.hasPort || u.userInfo.isEmpty) throw const FormatException('vless');
  return ProxyNode(
    protocol: 'vless',
    name: parts.name.isEmpty ? '${u.host}:${u.port}' : parts.name,
    server: u.host,
    port: u.port,
    uuid: _decode(u.userInfo),
    flow: _nonEmpty(q['flow']),
    security: (q['security'] ?? 'none').toLowerCase(),
    sni: _nonEmpty(q['sni']) ?? _nonEmpty(q['peer']),
    fingerprint: _nonEmpty(q['fp']),
    alpn: _list(q['alpn']),
    allowInsecure: _truthy(q['allowInsecure'] ?? q['insecure']),
    realityPublicKey: _nonEmpty(q['pbk']),
    realityShortId: _nonEmpty(q['sid']),
    network: _network(q['type']),
    path: _nonEmpty(q['path']),
    host: _nonEmpty(q['host']),
    serviceName: _nonEmpty(q['serviceName']),
  );
}

ProxyNode _trojan(String link) {
  final parts = _split(link);
  final u = Uri.parse(parts.base);
  final q = u.queryParameters;
  if (u.host.isEmpty || !u.hasPort || u.userInfo.isEmpty) throw const FormatException('trojan');
  return ProxyNode(
    protocol: 'trojan',
    name: parts.name.isEmpty ? '${u.host}:${u.port}' : parts.name,
    server: u.host,
    port: u.port,
    password: _decode(u.userInfo),
    security: (q['security'] ?? 'tls').toLowerCase(),
    sni: _nonEmpty(q['sni']) ?? _nonEmpty(q['peer']),
    fingerprint: _nonEmpty(q['fp']),
    alpn: _list(q['alpn']),
    allowInsecure: _truthy(q['allowInsecure'] ?? q['insecure']),
    realityPublicKey: _nonEmpty(q['pbk']),
    realityShortId: _nonEmpty(q['sid']),
    network: _network(q['type']),
    path: _nonEmpty(q['path']),
    host: _nonEmpty(q['host']),
    serviceName: _nonEmpty(q['serviceName']),
  );
}

ProxyNode _vmess(String link) {
  var body = link.substring('vmess://'.length);
  final hash = body.indexOf('#');
  if (hash >= 0) body = body.substring(0, hash);
  final j = jsonDecode(decodeBase64Loose(body));
  if (j is! Map) throw const FormatException('vmess');
  String s(String k) => (j[k] ?? '').toString();
  final port = int.tryParse(s('port'));
  final server = s('add');
  if (port == null || server.isEmpty || s('id').isEmpty) throw const FormatException('vmess');
  final net = _network(s('net'));
  return ProxyNode(
    protocol: 'vmess',
    name: s('ps').isEmpty ? '$server:$port' : s('ps'),
    server: server,
    port: port,
    uuid: s('id'),
    security: s('tls').toLowerCase() == 'tls' ? 'tls' : 'none',
    sni: _nonEmpty(s('sni')),
    fingerprint: _nonEmpty(s('fp')),
    alpn: _list(s('alpn')),
    network: net,
    path: _nonEmpty(s('path')),
    host: _nonEmpty(s('host')),
    serviceName: net == 'grpc' ? _nonEmpty(s('path')) : null,
    alterId: int.tryParse(s('aid')) ?? 0,
    vmessSecurity: _nonEmpty(s('scy')) ?? 'auto',
  );
}

ProxyNode _shadowsocks(String link) {
  final parts = _split(link);
  var body = parts.base.substring('ss://'.length);
  final q = body.indexOf('?');
  if (q >= 0) body = body.substring(0, q);
  body = body.replaceAll(RegExp(r'/+$'), '');

  String userinfo;
  String hostPort;
  final at = body.lastIndexOf('@');
  if (at >= 0) {
    userinfo = _decode(body.substring(0, at));
    hostPort = body.substring(at + 1);
    if (!userinfo.contains(':')) userinfo = decodeBase64Loose(userinfo);
  } else {
    final decoded = decodeBase64Loose(body);
    final a = decoded.lastIndexOf('@');
    if (a < 0) throw const FormatException('ss');
    userinfo = decoded.substring(0, a);
    hostPort = decoded.substring(a + 1);
  }
  final c = userinfo.indexOf(':');
  if (c <= 0) throw const FormatException('ss');
  final hp = _hostPort(hostPort);
  return ProxyNode(
    protocol: 'shadowsocks',
    name: parts.name.isEmpty ? '${hp.host}:${hp.port}' : parts.name,
    server: hp.host,
    port: hp.port,
    method: userinfo.substring(0, c),
    password: userinfo.substring(c + 1),
  );
}

ProxyNode _hysteria2(String link) {
  final parts = _split(link);
  final u = Uri.parse(parts.base);
  final q = u.queryParameters;
  if (u.host.isEmpty) throw const FormatException('hysteria2');
  final port = u.hasPort ? u.port : 443;
  return ProxyNode(
    protocol: 'hysteria2',
    name: parts.name.isEmpty ? '${u.host}:$port' : parts.name,
    server: u.host,
    port: port,
    password: _decode(u.userInfo),
    security: 'tls',
    sni: _nonEmpty(q['sni']),
    allowInsecure: _truthy(q['insecure']),
    alpn: _list(q['alpn']),
    obfs: _nonEmpty(q['obfs']),
    obfsPassword: _nonEmpty(q['obfs-password']),
  );
}

ProxyNode _tuic(String link) {
  final parts = _split(link);
  final u = Uri.parse(parts.base);
  final q = u.queryParameters;
  if (u.host.isEmpty || !u.hasPort) throw const FormatException('tuic');
  final info = _decode(u.userInfo);
  final c = info.indexOf(':');
  if (c <= 0) throw const FormatException('tuic');
  return ProxyNode(
    protocol: 'tuic',
    name: parts.name.isEmpty ? '${u.host}:${u.port}' : parts.name,
    server: u.host,
    port: u.port,
    uuid: info.substring(0, c),
    password: info.substring(c + 1),
    security: 'tls',
    sni: _nonEmpty(q['sni']),
    allowInsecure: _truthy(q['allow_insecure'] ?? q['allowInsecure'] ?? q['insecure']),
    alpn: _list(q['alpn']),
    congestion: _nonEmpty(q['congestion_control']),
    udpRelayMode: _nonEmpty(q['udp_relay_mode']),
  );
}
