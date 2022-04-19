/*
 * @FilePath     : /hik_player_android/lib/src/hik_view_platform_impl.dart
 * @Date         : 2022-04-19 15:14:53
 * @Author       : jawa0919 <jawa0919@163.com>
 * @Description  : hik_view_platform_impl
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hik_player_platform_interface/hik_player_platform_interface.dart';

import 'hik_view_widget.dart';

class HikViewPlatformImpl implements HikViewPlatform {
  @override
  Widget build(
      {required BuildContext context,
      HikViewPlatformCreatedCallback? onHikViewPlatformCreated}) {
    return HikViewWidget(onHikViewPlatformCreated: onHikViewPlatformCreated);
  }
}

class HikViewPlatformImplController implements HikViewPlatformController {
  MethodChannel? _channel;

  void init(int id) {
    _channel = MethodChannel('top.jawa0919/hik_player_controller_$id');
    _channel?.setMethodCallHandler((methodCall) async {
      switch (methodCall.method) {
        case "onPlayerStatusCallback":
        case "onTalkStatusCallback":
          // int status = methodCall.arguments["status"] ?? 0;
          // onHikStatusCallback?.call(HikStatus.values[status]);
          break;
        default:
      }
    });
  }

  @override
  Future<void> startRealPlay(String liveRtspUrl) {
    throw UnimplementedError();
  }

  Future<void> dispose() async {}
}
