/*
 * @FilePath     : /hik_player_android/lib/src/hik_view_widget.dart
 * @Date         : 2022-04-19 15:26:46
 * @Author       : jawa0919 <jawa0919@163.com>
 * @Description  : hik_view_widget
 */

import 'package:flutter/material.dart';
import 'package:hik_player_platform_interface/hik_player_platform_interface.dart';

import 'hik_view_platform_impl.dart';

class HikViewWidget extends StatefulWidget {
  final HikViewPlatformCreatedCallback? onHikViewPlatformCreated;
  const HikViewWidget({Key? key, required this.onHikViewPlatformCreated})
      : super(key: key);

  @override
  State<HikViewWidget> createState() => _HikViewWidgetState();
}

class _HikViewWidgetState extends State<HikViewWidget> {
  HikViewPlatformImplController _controller = HikViewPlatformImplController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AndroidView(
      viewType: "top.jawa0919/hik_player",
      onPlatformViewCreated: (int id) {
        _controller.init(id);
        if (widget.onHikViewPlatformCreated != null) {
          widget.onHikViewPlatformCreated!(_controller);
        }
      },
    );
  }
}
