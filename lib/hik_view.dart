/*
 * @FilePath     : /hik_player/lib/hik_view.dart
 * @Date         : 2021-10-27 09:31:58
 * @Author       : jawa0919 <jawa0919@163.com>
 * @Description  : HikView
 */

import 'dart:io';

import 'package:flutter/material.dart';

import 'hik_controller.dart';

class HikView extends StatefulWidget {
  final double aspectRatio;
  final HikControllerCallback onHikCreated;
  final Widget? overlay;

  const HikView({
    Key? key,
    this.aspectRatio = 16 / 9,
    required this.onHikCreated,
    this.overlay,
  }) : super(key: key);

  @override
  _HikViewState createState() => _HikViewState();
}

class _HikViewState extends State<HikView> with WidgetsBindingObserver {
  HikController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        debugPrint("_HikViewState AppLifecycleState.inactive");
        break;
      case AppLifecycleState.paused:
        // _controller?.onPause();
        debugPrint("_HikViewState AppLifecycleState.paused");
        break;
      case AppLifecycleState.resumed:
        // _controller?.onResume();
        debugPrint("_HikViewState AppLifecycleState.resumed");
        break;
      case AppLifecycleState.detached:
        debugPrint("_HikViewState AppLifecycleState.detached");
        break;
      default:
        debugPrint("_HikViewState default");
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: Stack(
          children: [
            _platformView(context),
            widget.overlay ?? Container(),
          ],
        ),
      ),
    );
  }

  Widget _platformView(BuildContext context) {
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: "hik_player.viewType",
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: "hik_player.viewType",
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
    return const Center(child: Text("Unsupported Platform"));
  }

  void _onPlatformViewCreated(int id) {
    final _ctrl = HikController.init(id);
    _controller = _ctrl;
    widget.onHikCreated(_ctrl);
  }
}
