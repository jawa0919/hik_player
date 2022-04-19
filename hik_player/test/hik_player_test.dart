// Copyright (c) 2022, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter_test/flutter_test.dart';
import 'package:hik_player/hik_player.dart';
import 'package:hik_player_platform_interface/hik_player_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockHikPlayerPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements HikPlayerPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HikPlayer', () {
    late HikPlayerPlatform hikPlayerPlatform;

    setUp(() {
      hikPlayerPlatform = MockHikPlayerPlatform();
      HikPlayerPlatform.instance = hikPlayerPlatform;
    });

    group('getPlatformName', () {
      test('returns correct name when platform implementation exists',
          () async {
        const platformName = '__test_platform__';
        when(
          () => hikPlayerPlatform.getPlatformName(),
        ).thenAnswer((_) async => platformName);

        final actualPlatformName = await getPlatformName();
        expect(actualPlatformName, equals(platformName));
      });

      test('throws exception when platform implementation is missing',
          () async {
        when(
          () => hikPlayerPlatform.getPlatformName(),
        ).thenAnswer((_) async => null);

        expect(getPlatformName, throwsException);
      });
    });
  });
}
