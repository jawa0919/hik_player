// Copyright (c) 2022, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:hik_player_platform_interface/src/method_channel_hik_player.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that implementations of hik_player must implement.
///
/// Platform implementations should extend this class
/// rather than implement it as `HikPlayer`.
/// Extending this class (using `extends`) ensures that the subclass will get
/// the default implementation, while platform implementations that `implements`
///  this interface will be broken by newly added [HikPlayerPlatform] methods.
abstract class HikPlayerPlatform extends PlatformInterface {
  /// Constructs a HikPlayerPlatform.
  HikPlayerPlatform() : super(token: _token);

  static final Object _token = Object();

  static HikPlayerPlatform _instance = MethodChannelHikPlayer();

  /// The default instance of [HikPlayerPlatform] to use.
  ///
  /// Defaults to [MethodChannelHikPlayer].
  static HikPlayerPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [HikPlayerPlatform] when they register themselves.
  static set instance(HikPlayerPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Return the current platform name.
  Future<String?> getPlatformName();
}
