/*
 * @FilePath     : /hik_player/lib/hik_scaffold.dart
 * @Date         : 2021-10-27 09:39:55
 * @Author       : jawa0919 <jawa0919@163.com>
 * @Description  : HikScaffold
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'hik_controller.dart';
import 'hik_view.dart';

class HikScaffold extends StatefulWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;

  final HikControllerCallback onHikCreated;
  final List<DeviceOrientation> deviceOrientations;
  final List<DeviceOrientation> deviceOrientationsOnFullScreen;

  const HikScaffold({
    Key? key,
    this.appBar,
    this.body,
    required this.onHikCreated,
    this.deviceOrientations = const [DeviceOrientation.portraitUp],
    this.deviceOrientationsOnFullScreen = const [
      DeviceOrientation.landscapeLeft
    ],
  }) : super(key: key);

  @override
  _HikScaffoldState createState() => _HikScaffoldState();
}

class _HikScaffoldState extends State<HikScaffold> {
  HikController? _ctrl;
  HikStatus _status = HikStatus.IDLE;

  bool _isFullScreen = false;
  Timer? _hideTimer;
  bool _showControl = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
      SystemChrome.setPreferredOrientations(widget.deviceOrientations);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(children: [
        SizedBox(
          width: size.width < size.height ? size.width : null,
          height: size.width < size.height ? null : size.height,
          child: HikView(
            aspectRatio: 16 / 9,
            onHikCreated: _onHikCreated,
            overlay: GestureDetector(
              onTap: () => _showControlView(context),
              child: _buildControls(context),
            ),
          ),
        ),
        Expanded(child: _buildBody(context))
      ]),
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    return _isFullScreen ? null : widget.appBar;
  }

  void _onHikCreated(HikController controller) {
    _ctrl = controller;
    widget.onHikCreated(controller);
    controller.setHikStatusCallback(_onHikStatusCallback);
  }

  void _onHikStatusCallback(HikStatus status) {
    _status = status;
    setState(() {});
  }

  void _showControlView(BuildContext context) {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 2), () {
      _showControl = false;
      setState(() {});
    });
    _showControl = true;
    setState(() {});
  }

  Widget _buildControls(BuildContext context) {
    return AbsorbPointer(
      absorbing: !_showControl,
      child: Column(
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _showControl ? 1.0 : 0.0,
            child: _buildControlsActionBar(context),
          ),
          Expanded(child: _buildControlsCenter(context)),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _showControl ? 1.0 : 0.0,
            child: _buildControlsBottomBar(context),
          )
        ],
      ),
    );
  }

  Widget _buildControlsActionBar(BuildContext context) {
    return Container();
  }

  Widget _buildControlsCenter(BuildContext context) {
    if (_status == HikStatus.LOADING) {
      return const Center(child: CircularProgressIndicator());
    }
    return Container();
  }

  Widget _buildControlsBottomBar(BuildContext context) {
    return Container(
      height: 40,
      width: double.infinity,
      color: Colors.black45.withAlpha(80),
      child: Row(children: [
        Expanded(child: Container()),
        IconButton(
          onPressed: () => _onTapFullScreen(context),
          color: Colors.white70,
          icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
        )
      ]),
    );
  }

  void _onTapFullScreen(BuildContext context) {
    _isFullScreen = !_isFullScreen;
    setState(() {});
    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
      SystemChrome.setPreferredOrientations(
          widget.deviceOrientationsOnFullScreen);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
      SystemChrome.setPreferredOrientations(widget.deviceOrientations);
    }
  }

  Widget _buildBody(BuildContext context) {
    Widget body = widget.body ?? Container();
    return _isFullScreen ? Container() : body;
  }
}
