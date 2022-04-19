/*
 * @FilePath     : /hik_player_platform_interface/lib/src/hik_view_platform_controller.dart
 * @Date         : 2022-04-19 14:48:36
 * @Author       : jawa0919 <jawa0919@163.com>
 * @Description  : hik_view_platform_controller
 */

/// 控制器
abstract class HikViewPlatformController {
  /// 开始预览
  Future<void> startRealPlay(String liveRtspUrl) {
    throw UnimplementedError(
        'HikView startRealPlay is not implemented on the current platform');
  }
}
