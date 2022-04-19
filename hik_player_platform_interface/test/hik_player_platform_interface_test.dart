// Copyright (c) 2022, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter_test/flutter_test.dart';
import 'package:hik_player_platform_interface/hik_player_platform_interface.dart';

class HikPlayerMock extends HikPlayerPlatform {
  static const mockPlatformName = 'Mock';

  @override
  Future<String?> getPlatformName() async => mockPlatformName;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('HikPlayerPlatformInterface', () {
    late HikPlayerPlatform hikPlayerPlatform;

    setUp(() {
      hikPlayerPlatform = HikPlayerMock();
      HikPlayerPlatform.instance = hikPlayerPlatform;
    });

    group('getPlatformName', () {
      test('returns correct name', () async {
        expect(
          await HikPlayerPlatform.instance.getPlatformName(),
          equals(HikPlayerMock.mockPlatformName),
        );
      });
    });
  });
}
