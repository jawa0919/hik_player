library hik_player;

import 'dart:async';

import 'package:flutter/services.dart';

export './hik_api.dart';
export './hik_controller.dart';
export './hik_player_page.dart';
export './hik_scaffold.dart';
export './hik_view.dart';
export './relative_layout.dart';

class HikPlayer {
  static const MethodChannel _channel = MethodChannel('hik_player');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
