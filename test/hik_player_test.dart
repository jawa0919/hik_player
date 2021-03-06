import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hik_player/hik_player.dart';

void main() {
  const MethodChannel channel = MethodChannel('hik_player');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await HikPlayer.platformVersion, '42');
  });
}
