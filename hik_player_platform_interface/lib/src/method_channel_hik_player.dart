import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
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
