// Copyright (c) 2022, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hik_player_android/hik_player_android.dart';
import 'package:hik_player_platform_interface/hik_player_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HikPlayerAndroid', () {
    const kPlatformName = 'Android';
    late HikPlayerAndroid hikPlayer;
    late List<MethodCall> log;

    setUp(() async {
      hikPlayer = HikPlayerAndroid();

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
      HikPlayerAndroid.registerWith();
      expect(HikPlayerPlatform.instance, isA<HikPlayerAndroid>());
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
