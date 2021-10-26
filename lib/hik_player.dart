
import 'dart:async';

import 'package:flutter/services.dart';

class HikPlayer {
  static const MethodChannel _channel = MethodChannel('hik_player');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
