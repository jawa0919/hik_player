import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:hik_player_platform_interface/hik_player_platform_interface.dart';

/// An implementation of [HikPlayerPlatform] that uses method channels.
class MethodChannelHikPlayer extends HikPlayerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('hik_player');

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }
}
