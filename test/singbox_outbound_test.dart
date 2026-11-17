import 'package:ampire/core/link_parser.dart';
import 'package:ampire/core/singbox_outbound.dart';
import 'package:flutter_test/flutter_test.dart';

const uuid = '11111111-2222-3333-4444-555555555555';

Map<String, dynamic> out(String link) => buildSingBoxOutbound(parseLink(link)!)!;

void main() {
  test('vless reality', () {
    final o = out('vless://$uuid@e.com:443?flow=xtls-rprx-vision&security=reality&sni=www.microsoft.com&fp=chrome&pbk=PK&sid=ab&type=tcp');
    expect(o['type'], 'vless');
    expect(o['tag'], 'proxy');
    expect(o['server_port'], 443);
    expect(o['flow'], 'xtls-rprx-vision');
    final tls = o['tls'] as Map<String, dynamic>;
    expect(tls['server_name'], 'www.microsoft.com');
    expect((tls['reality'] as Map)['public_key'], 'PK');
    expect((tls['reality'] as Map)['short_id'], 'ab');
    expect((tls['utls'] as Map)['fingerprint'], 'chrome');
    expect(o.containsKey('transport'), isFalse);
  });

  test('vless ws tls', () {
    final o = out('vless://$uuid@e.com:443?type=ws&security=tls&path=%2Fws&host=h.example.com');
    final tr = o['transport'] as Map<String, dynamic>;
    expect(tr['type'], 'ws');
    expect(tr['path'], '/ws');
    expect((tr['headers'] as Map)['Host'], 'h.example.com');
    expect((o['tls'] as Map)['server_name'], 'h.example.com');
  });

  test('trojan grpc', () {
    final o = out('trojan://pw@e.com:443?type=grpc&serviceName=svc&sni=e.com');
    expect(o['type'], 'trojan');
    expect(o['password'], 'pw');
    expect((o['transport'] as Map)['service_name'], 'svc');
  });

  test('shadowsocks без tls', () {
    final o = out('ss://aes-256-gcm:secret@1.2.3.4:8388');
    expect(o['method'], 'aes-256-gcm');
    expect(o['password'], 'secret');
    expect(o.containsKey('tls'), isFalse);
  });

  test('hysteria2 с obfs, tls включён всегда', () {
    final o = out('hysteria2://s@h.example.com:8443?insecure=1&obfs=salamander&obfs-password=o');
    expect(o['type'], 'hysteria2');
    expect((o['obfs'] as Map)['type'], 'salamander');
    expect((o['obfs'] as Map)['password'], 'o');
    expect((o['tls'] as Map)['enabled'], isTrue);
    expect((o['tls'] as Map)['insecure'], isTrue);
  });

  test('tuic: значения по умолчанию', () {
    final o = out('tuic://$uuid:pw@t.example.com:443?sni=t.example.com');
    expect(o['congestion_control'], 'bbr');
    expect(o['udp_relay_mode'], 'native');
  });

  test('xhttp и kcp в sing-box не собираются', () {
    expect(buildSingBoxOutbound(parseLink('vless://$uuid@e.com:443?type=xhttp&security=tls')!), isNull);
    expect(buildSingBoxOutbound(parseLink('vless://$uuid@e.com:443?type=kcp&security=none')!), isNull);
  });
}
