import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma_app/core/network/dio_client.dart';

String makeJwt({required Duration expiresIn}) {
  final header =
      base64UrlEncode(utf8.encode('{"alg":"HS256","typ":"JWT"}')).replaceAll('=', '');
  final exp = DateTime.now().add(expiresIn).millisecondsSinceEpoch ~/ 1000;
  final payload =
      base64UrlEncode(utf8.encode(jsonEncode({'exp': exp}))).replaceAll('=', '');
  return '$header.$payload.fake-signature';
}

void main() {
  group('isAccessTokenExpiringSoon', () {
    test('توکن با انقضای دور → نزدیک انقضا نیست', () {
      final token = makeJwt(expiresIn: const Duration(minutes: 30));
      expect(isAccessTokenExpiringSoon(token), isFalse);
    });

    test('توکن در آستانه انقضا (کمتر از ۲ دقیقه) → نزدیک انقضا است', () {
      final token = makeJwt(expiresIn: const Duration(seconds: 30));
      expect(isAccessTokenExpiringSoon(token), isTrue);
    });

    test('توکن منقضی → نزدیک انقضا است', () {
      final token = makeJwt(expiresIn: const Duration(seconds: -10));
      expect(isAccessTokenExpiringSoon(token), isTrue);
    });

    test('توکن نامعتبر (بدون ۳ بخش) → نزدیک انقضا تلقی می‌شود', () {
      expect(isAccessTokenExpiringSoon('not-a-jwt'), isTrue);
    });

    test('توکن بدون exp → نزدیک انقضا تلقی می‌شود', () {
      final payload =
          base64UrlEncode(utf8.encode(jsonEncode({'id': 'x'}))).replaceAll('=', '');
      final token = 'a.$payload.c';
      expect(isAccessTokenExpiringSoon(token), isTrue);
    });
  });
}
