// Copyright (c) 2022, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hik_player_platform_interface/hik_player_platform_interface.dart';

/// The Android implementation of [HikPlayerPlatform].
class HikPlayerAndroid extends HikPlayerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('hik_player_android');

  /// Registers this class as the default instance of [HikPlayerPlatform]
  static void registerWith() {
    HikPlayerPlatform.instance = HikPlayerAndroid();
  }

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }
}
