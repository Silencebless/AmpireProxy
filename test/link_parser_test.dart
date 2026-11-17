import 'dart:convert';

import 'package:ampire/core/link_parser.dart';
import 'package:flutter_test/flutter_test.dart';

String b64(String s) => base64.encode(utf8.encode(s));
String b64url(String s) => base64Url.encode(utf8.encode(s)).replaceAll('=', '');

void main() {
  const uuid = '11111111-2222-3333-4444-555555555555';

  test('vless reality', () {
    final n = parseLink(
        'vless://$uuid@example.com:443?encryption=none&flow=xtls-rprx-vision&security=reality&sni=www.microsoft.com&fp=chrome&pbk=PUBKEY&sid=abcd&type=tcp#My%20Node')!;
    expect(n.protocol, 'vless');
    expect(n.name, 'My Node');
    expect(n.server, 'example.com');
    expect(n.port, 443);
    expect(n.uuid, uuid);
    expect(n.flow, 'xtls-rprx-vision');
    expect(n.security, 'reality');
    expect(n.sni, 'www.microsoft.com');
    expect(n.fingerprint, 'chrome');
    expect(n.realityPublicKey, 'PUBKEY');
    expect(n.realityShortId, 'abcd');
    expect(n.network, 'tcp');
    expect(n.needsXray, isFalse);
  });

  test('vless ws tls и xhttp', () {
    final ws = parseLink('vless://$uuid@h.example.com:443?type=ws&security=tls&sni=s.example.com&path=%2Fws&host=s.example.com#ws')!;
    expect(ws.network, 'ws');
    expect(ws.path, '/ws');
    expect(ws.host, 's.example.com');
    expect(ws.security, 'tls');
    final x = parseLink('vless://$uuid@h.example.com:443?type=xhttp&security=tls&path=%2Fx#x')!;
    expect(x.needsXray, isTrue);
  });

  test('vless: без имени подставляется адрес, IPv6 допустим', () {
    final n = parseLink('vless://$uuid@[2001:db8::1]:8443?security=none')!;
    expect(n.server, '2001:db8::1');
    expect(n.port, 8443);
    expect(n.name, '2001:db8::1:8443');
  });

  test('vmess', () {
    final json = jsonEncode({
      'v': '2', 'ps': 'VM', 'add': 'vm.example.com', 'port': '443', 'id': uuid, 'aid': '0',
      'scy': 'auto', 'net': 'ws', 'type': 'none', 'host': 'vm.example.com', 'path': '/vm', 'tls': 'tls', 'sni': 'vm.example.com',
    });
    final n = parseLink('vmess://${b64(json)}')!;
    expect(n.protocol, 'vmess');
    expect(n.name, 'VM');
    expect(n.port, 443);
    expect(n.network, 'ws');
    expect(n.security, 'tls');
    expect(n.path, '/vm');
    expect(n.uuid, uuid);
  });

  test('trojan с экранированным паролем и grpc', () {
    final n = parseLink('trojan://pass%40word@t.example.com:443?sni=t.example.com&type=grpc&serviceName=svc#T')!;
    expect(n.protocol, 'trojan');
    expect(n.password, 'pass@word');
    expect(n.network, 'grpc');
    expect(n.serviceName, 'svc');
    expect(n.security, 'tls');
  });

  test('shadowsocks: SIP002, открытый вид, старый вид и IPv6', () {
    final a = parseLink('ss://${b64url('aes-256-gcm:secret')}@1.2.3.4:8388#ss')!;
    expect([a.method, a.password, a.server, a.port, a.name], ['aes-256-gcm', 'secret', '1.2.3.4', 8388, 'ss']);
    final b = parseLink('ss://aes-256-gcm:secret@1.2.3.4:8388#ss2')!;
    expect([b.method, b.password, b.name], ['aes-256-gcm', 'secret', 'ss2']);
    final c = parseLink('ss://${b64('aes-256-gcm:secret@1.2.3.4:8388')}#ss3')!;
    expect([c.method, c.server, c.port, c.name], ['aes-256-gcm', '1.2.3.4', 8388, 'ss3']);
    final d = parseLink('ss://${b64url('chacha20-ietf-poly1305:p')}@[2001:db8::1]:8388#v6')!;
    expect([d.server, d.port], ['2001:db8::1', 8388]);
  });

  test('hysteria2 и псевдоним hy2', () {
    final n = parseLink('hysteria2://secret@h.example.com:8443?sni=h.example.com&insecure=1&obfs=salamander&obfs-password=o#hy')!;
    expect(n.protocol, 'hysteria2');
    expect(n.password, 'secret');
    expect(n.sni, 'h.example.com');
    expect(n.allowInsecure, isTrue);
    expect(n.obfs, 'salamander');
    expect(n.obfsPassword, 'o');
    final m = parseLink('hy2://s@h.example.com#d')!;
    expect(m.port, 443);
    expect(m.protocol, 'hysteria2');
  });

  test('tuic', () {
    final n = parseLink('tuic://$uuid:pwd@t.example.com:443?congestion_control=bbr&udp_relay_mode=native&alpn=h3&sni=t.example.com#tu')!;
    expect(n.protocol, 'tuic');
    expect(n.uuid, uuid);
    expect(n.password, 'pwd');
    expect(n.alpn, ['h3']);
    expect(n.congestion, 'bbr');
    expect(n.udpRelayMode, 'native');
  });

  test('повреждённые и неизвестные ссылки дают null', () {
    for (final bad in [
      '',
      'просто текст',
      'http://example.com',
      'vless://bad',
      'vless://$uuid@host',
      'ss://%%%',
      'vmess://не-base64!',
      'tuic://x@h:1',
      'trojan://@h:1',
    ]) {
      expect(parseLink(bad), isNull, reason: bad);
    }
  });

  test('decodeBase64Loose понимает оба алфавита и отсутствие выравнивания', () {
    expect(decodeBase64Loose('aGVsbG8'), 'hello');
    expect(decodeBase64Loose('aGVsbG8='), 'hello');
    expect(decodeBase64Loose(b64url('??>>')), '??>>');
    expect(() => decodeBase64Loose('a'), throwsFormatException);
  });
}
