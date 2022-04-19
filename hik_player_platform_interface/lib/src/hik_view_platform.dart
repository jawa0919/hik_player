/*
 * @FilePath     : /hik_player_platform_interface/lib/src/hik_view_platform.dart
 * @Date         : 2022-04-19 14:46:05
 * @Author       : jawa0919 <jawa0919@163.com>
 * @Description  : hik_view_platform
 */

import 'package:flutter/material.dart';
import 'package:hik_player_platform_interface/src/hik_view_platform_controller.dart';

/// 构建成功的函数返回
typedef HikViewPlatformCreatedCallback = void Function(
    HikViewPlatformController? hikViewPlatformController);

/// 视图台
abstract class HikViewPlatform {
  /// 构建
  Widget build({
    required BuildContext context,
    HikViewPlatformCreatedCallback? onHikViewPlatformCreated,
  }) {
    throw UnimplementedError(
        'HikViewPlatform build is not implemented on the current platform');
  }
}
