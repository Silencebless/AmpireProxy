import 'dart:convert';

import 'package:ampire/core/link_parser.dart';
import 'package:ampire/core/subscription_parser.dart';
import 'package:flutter_test/flutter_test.dart';

const uuid = '11111111-2222-3333-4444-555555555555';
final links = [
  'vless://$uuid@a.example.com:443?security=tls&sni=a.example.com#A',
  'trojan://pw@b.example.com:443#B',
  'ss://aes-256-gcm:secret@1.2.3.4:8388#C',
];

void main() {
  test('открытый список ссылок: мусор пропускается и считается', () {
    final body = '${links.join('\n')}\nvless://broken\n# комментарий\n';
    final r = parseSubscription(body);
    expect(r.nodes.map((n) => n.name), ['A', 'B', 'C']);
    expect(r.skipped, 1);
  });

  test('список ссылок в base64', () {
    final body = base64.encode(utf8.encode(links.join('\r\n')));
    final r = parseSubscription(body);
    expect(r.nodes.length, 3);
    expect(r.skipped, 0);
  });

  test('повторы убираются', () {
    final r = parseSubscription('${links[0]}\n${links[0]}\n${links[1]}');
    expect(r.nodes.length, 2);
  });

  test('JSON и непонятный текст отклоняются', () {
    expect(() => parseSubscription('{"outbounds":[]}'), throwsFormatException);
    expect(() => parseSubscription('просто текст'), throwsFormatException);
    expect(() => parseSubscription(''), throwsFormatException);
  });

  test('заголовки Remnawave: трафик, срок, название, интервал', () {
    final title = 'base64:${base64.encode(utf8.encode('Мой сервис'))}';
    final m = parseSubscriptionHeaders({
      'Subscription-Userinfo': 'upload=100; download=200; total=1000; expire=2000000000',
      'Profile-Title': title,
      'Profile-Update-Interval': '12',
      'Support-URL': 'https://t.me/support',
      'Announce': 'base64:${base64.encode(utf8.encode('Привет'))}',
    });
    expect(m.title, 'Мой сервис');
    expect(m.updateIntervalHours, 12);
    expect(m.usedBytes, 300);
    expect(m.totalBytes, 1000);
    expect(m.supportUrl, 'https://t.me/support');
    expect(m.announce, 'Привет');
    expect(m.expireAt, DateTime.fromMillisecondsSinceEpoch(2000000000 * 1000, isUtc: true));
    expect(m.daysLeft(DateTime.utc(2033, 5, 17, 12)), 1);
    expect(m.daysLeft(DateTime.utc(2040)), 0);
  });

  test('без заголовков значения по умолчанию', () {
    final m = parseSubscriptionHeaders(const {});
    expect(m.title, isNull);
    expect(m.totalBytes, 0);
    expect(m.expireAt, isNull);
    expect(m.daysLeft(DateTime.utc(2030)), isNull);
  });

  test('заголовки передаются вместе с телом', () {
    final r = parseSubscription(links[0], headers: {'profile-title': 'Тест'});
    expect(r.meta.title, 'Тест');
  });

  test('нода получает имя из подписки', () {
    expect(parseLink(links[2])!.name, 'C');
  });
}
