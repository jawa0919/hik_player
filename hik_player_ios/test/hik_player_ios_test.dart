// Copyright (c) 2022, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hik_player_ios/hik_player_ios.dart';
import 'package:hik_player_platform_interface/hik_player_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HikPlayerIOS', () {
    const kPlatformName = 'iOS';
    late HikPlayerIOS hikPlayer;
    late List<MethodCall> log;

    setUp(() async {
      hikPlayer = HikPlayerIOS();

      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger
          .setMockMethodCallHandler(hikPlayer.methodChannel, (methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'getPlatformName':
            return kPlatformName;
          default:
            return null;
        }
      });
    });

    test('can be registered', () {
      HikPlayerIOS.registerWith();
      expect(HikPlayerPlatform.instance, isA<HikPlayerIOS>());
    });

    test('getPlatformName returns correct name', () async {
      final name = await hikPlayer.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(name, equals(kPlatformName));
    });
  });
}
