import 'proxy_node.dart';

/// Исходящее соединение sing-box для ноды. Для нод, которым нужен Xray-core
/// (xhttp) или транспорт без поддержки в sing-box, возвращает null.
Map<String, dynamic>? buildSingBoxOutbound(ProxyNode n, {String tag = 'proxy'}) {
  if (n.needsXray) return null;
  final transport = _transport(n);
  if (transport == null && n.network != 'tcp') return null;

  final o = <String, dynamic>{
    'type': n.protocol,
    'tag': tag,
    'server': n.server,
    'server_port': n.port,
  };
  switch (n.protocol) {
    case 'vless':
      o['uuid'] = n.uuid;
      if (n.flow != null) o['flow'] = n.flow;
    case 'vmess':
      o['uuid'] = n.uuid;
      o['security'] = n.vmessSecurity;
      o['alter_id'] = n.alterId;
    case 'trojan':
      o['password'] = n.password;
    case 'shadowsocks':
      o['method'] = n.method;
      o['password'] = n.password;
    case 'hysteria2':
      o['password'] = n.password;
      if (n.obfs != null) {
        o['obfs'] = <String, dynamic>{'type': n.obfs, 'password': n.obfsPassword ?? ''};
      }
    case 'tuic':
      o['uuid'] = n.uuid;
      o['password'] = n.password;
      o['congestion_control'] = n.congestion ?? 'bbr';
      o['udp_relay_mode'] = n.udpRelayMode ?? 'native';
    default:
      return null;
  }
  final tls = _tls(n);
  if (tls != null) o['tls'] = tls;
  if (transport != null) o['transport'] = transport;
  return o;
}

Map<String, dynamic>? _tls(ProxyNode n) {
  final always = n.protocol == 'hysteria2' || n.protocol == 'tuic';
  if (!always && n.security != 'tls' && n.security != 'reality') return null;
  final t = <String, dynamic>{'enabled': true};
  final name = n.sni ?? n.host;
  if (name != null) t['server_name'] = name;
  if (n.allowInsecure) t['insecure'] = true;
  if (n.alpn.isNotEmpty) t['alpn'] = n.alpn;
  if (!always && n.fingerprint != null) {
    t['utls'] = <String, dynamic>{'enabled': true, 'fingerprint': n.fingerprint};
  }
  if (n.security == 'reality') {
    t['reality'] = <String, dynamic>{
      'enabled': true,
      'public_key': n.realityPublicKey ?? '',
      'short_id': n.realityShortId ?? '',
    };
    t['utls'] ??= <String, dynamic>{'enabled': true, 'fingerprint': 'chrome'};
  }
  return t;
}

Map<String, dynamic>? _transport(ProxyNode n) {
  switch (n.network) {
    case 'ws':
      return <String, dynamic>{
        'type': 'ws',
        'path': n.path ?? '/',
        if (n.host != null) 'headers': <String, dynamic>{'Host': n.host},
      };
    case 'grpc':
      return <String, dynamic>{'type': 'grpc', 'service_name': n.serviceName ?? n.path ?? ''};
    case 'httpupgrade':
      return <String, dynamic>{
        'type': 'httpupgrade',
        'path': n.path ?? '/',
        if (n.host != null) 'host': n.host,
      };
    case 'http':
      return <String, dynamic>{
        'type': 'http',
        'path': n.path ?? '/',
        if (n.host != null) 'host': <String>[n.host!],
      };
    default:
      return null;
  }
}
