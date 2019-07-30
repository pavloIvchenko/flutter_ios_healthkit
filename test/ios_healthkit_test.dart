import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_healthkit/ios_healthkit.dart';

void main() {
  const MethodChannel channel = MethodChannel('ios_healthkit');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await IosHealthkit.platformVersion, '42');
  });
}
