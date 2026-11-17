/// Нейтральное описание ноды, не привязанное к конкретному ядру.
class ProxyNode {
  const ProxyNode({
    required this.protocol,
    required this.name,
    required this.server,
    required this.port,
    this.uuid,
    this.password,
    this.method,
    this.flow,
    this.security = 'none',
    this.sni,
    this.fingerprint,
    this.alpn = const <String>[],
    this.allowInsecure = false,
    this.realityPublicKey,
    this.realityShortId,
    this.network = 'tcp',
    this.path,
    this.host,
    this.serviceName,
    this.obfs,
    this.obfsPassword,
    this.congestion,
    this.udpRelayMode,
    this.alterId = 0,
    this.vmessSecurity = 'auto',
  });

  /// vless, vmess, trojan, shadowsocks, hysteria2 или tuic.
  final String protocol;
  final String name;
  final String server;
  final int port;

  final String? uuid;
  final String? password;
  final String? method;
  final String? flow;

  /// none, tls или reality.
  final String security;
  final String? sni;
  final String? fingerprint;
  final List<String> alpn;
  final bool allowInsecure;
  final String? realityPublicKey;
  final String? realityShortId;

  /// tcp, ws, grpc, httpupgrade, http, xhttp, kcp, quic.
  final String network;
  final String? path;
  final String? host;
  final String? serviceName;

  final String? obfs;
  final String? obfsPassword;
  final String? congestion;
  final String? udpRelayMode;
  final int alterId;
  final String vmessSecurity;

  /// Транспорты, которых нет в sing-box: такие ноды нужно запускать через Xray-core.
  bool get needsXray => network == 'xhttp' || network == 'splithttp';
}
