/*
 * @FilePath     : /hik_player/lib/hik_player_page.dart
 * @Date         : 2021-10-27 09:53:17
 * @Author       : jawa0919 <jawa0919@163.com>
 * @Description  : HikPlayerPage
 */

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'hik_api.dart';
import 'hik_controller.dart';
import 'hik_scaffold.dart';
import 'relative_layout.dart';

class HikPlayerPage extends StatefulWidget {
  final String host;
  final String appKey;
  final String appSecret;
  final String cameraIndexCode;
  final int speed;
  final String title;

  const HikPlayerPage({
    Key? key,
    required this.host,
    required this.appKey,
    required this.appSecret,
    required this.cameraIndexCode,
    this.speed = 50,
    this.title = "",
  }) : super(key: key);

  @override
  _HikPlayerPageState createState() => _HikPlayerPageState();
}

class _HikPlayerPageState extends State<HikPlayerPage> {
  HikController? _ctrl;

  @override
  Widget build(BuildContext context) {
    return HikScaffold(
      appBar: widget.title.isEmpty ? null : AppBar(title: Text(widget.title)),
      body: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            OutlinedButton(
              child: const Text("截图"),
              onPressed: () => _captureLoc(context),
            ),
            OutlinedButton(child: const Text("放大"), onPressed: _zoonIn),
            OutlinedButton(child: const Text("缩小 "), onPressed: _zoonOut),
          ],
        ),
        Expanded(
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: RelativeLayout(
              children: <LayoutId>[
                LayoutId(
                  id: RelativeId('A'),
                  child: IconButton(
                    iconSize: 55,
                    padding: const EdgeInsets.all(0),
                    color: Colors.white,
                    icon: const Icon(Icons.circle),
                    onPressed: () {},
                  ),
                ),
                LayoutId(
                  id: RelativeId('B', above: 'A'),
                  child: GestureDetector(
                    child: Icon(
                      Icons.arrow_drop_up,
                      size: 40,
                      color: Colors.blue[400],
                    ),
                    onTap: () {
                      log("onTap");
                      _up();
                    },
                    onLongPressStart: (details) {
                      log("onLongPressStart");
                      HikApi.ptzsControlling(
                          widget.cameraIndexCode, 0, "UP", widget.speed);
                    },
                    onLongPressEnd: (details) {
                      log("onLongPressEnd");
                      HikApi.ptzsControlling(
                          widget.cameraIndexCode, 1, "UP", widget.speed);
                    },
                  ),
                ),
                LayoutId(
                  id: RelativeId('C', toRightOf: 'A'),
                  child: GestureDetector(
                    child: Icon(
                      Icons.arrow_right,
                      size: 40,
                      color: Colors.blue[400],
                    ),
                    onTap: () {
                      _right();
                    },
                    onLongPressStart: (details) {
                      HikApi.ptzsControlling(
                          widget.cameraIndexCode, 0, "RIGHT", widget.speed);
                    },
                    onLongPressEnd: (details) {
                      HikApi.ptzsControlling(
                          widget.cameraIndexCode, 1, "RIGHT", widget.speed);
                    },
                  ),
                ),
                LayoutId(
                  id: RelativeId('D', below: 'A'),
                  child: GestureDetector(
                    child: Icon(
                      Icons.arrow_drop_down,
                      size: 40,
                      color: Colors.blue[400],
                    ),
                    onTap: () {
                      _down();
                    },
                    onLongPressStart: (details) {
                      HikApi.ptzsControlling(
                          widget.cameraIndexCode, 0, "DOWN", widget.speed);
                    },
                    onLongPressEnd: (details) {
                      HikApi.ptzsControlling(
                          widget.cameraIndexCode, 1, "DOWN", widget.speed);
                    },
                  ),
                ),
                LayoutId(
                  id: RelativeId('E', toLeftOf: 'A'),
                  child: GestureDetector(
                    child: Icon(
                      Icons.arrow_left,
                      size: 40,
                      color: Colors.blue[400],
                    ),
                    onTap: () {
                      _left();
                    },
                    onLongPressStart: (details) {
                      HikApi.ptzsControlling(
                          widget.cameraIndexCode, 0, "LEFT", widget.speed);
                    },
                    onLongPressEnd: (details) {
                      HikApi.ptzsControlling(
                          widget.cameraIndexCode, 1, "LEFT", widget.speed);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
      onHikCreated: (HikController controller) {
        _ctrl = controller;
        _startReal();
      },
    );
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  String _previewUrl = "";
  void _startReal() async {
    HikApi.init(widget.host, widget.appKey, widget.appSecret);
    _previewUrl = await HikApi.previewURLs(widget.cameraIndexCode);
    await _ctrl?.startRealPlay(_previewUrl);
  }

  void _stop() async {
    await _ctrl?.stopPlay();
  }

  void _capture() async {
    final picUrl = await HikApi.manualCapture(widget.cameraIndexCode);
  }

  void _captureLoc(BuildContext context) async {
    final m = ScaffoldMessenger.of(context);
    if (await Permission.storage.request().isGranted) {
      final externalDirs = await getApplicationDocumentsDirectory();
      final externalPath = externalDirs.path;
      final path = '$externalPath/${DateTime.now().toString()}.jpg';
      m.showSnackBar(const SnackBar(content: Text("正在截图")));
      final res = await _ctrl?.capturePicture(path);
      debugPrint(res.toString());
      if (res["ret"]) {
        if (Platform.isAndroid) {
          final result = await ImageGallerySaver.saveFile(path);
          if (result["isSuccess"]) {
            m.showSnackBar(const SnackBar(content: Text("截图已保存到手机相册中")));
          } else {
            m.showSnackBar(const SnackBar(content: Text("保存截图失败")));
          }
        } else {
          m.showSnackBar(SnackBar(content: Text(res["msg"])));
        }
      } else {
        m.showSnackBar(SnackBar(content: Text(res["msg"])));
      }
    } else {
      m.showSnackBar(const SnackBar(content: Text("Some Permission Error")));
    }
  }

  void _zoonIn() async {
    await HikApi.ptzsControlling(
        widget.cameraIndexCode, 0, "ZOOM_IN", widget.speed);
    await Future.delayed(const Duration(milliseconds: 100));
    await HikApi.ptzsControlling(
        widget.cameraIndexCode, 1, "ZOOM_IN", widget.speed);
  }

  void _zoonOut() async {
    await HikApi.ptzsControlling(
        widget.cameraIndexCode, 0, "ZOOM_OUT", widget.speed);
    await Future.delayed(const Duration(milliseconds: 100));
    await HikApi.ptzsControlling(
        widget.cameraIndexCode, 1, "ZOOM_OUT", widget.speed);
  }

  void _up() async {
    await HikApi.ptzsControlling(widget.cameraIndexCode, 0, "UP", widget.speed);
    await Future.delayed(const Duration(milliseconds: 100));
    await HikApi.ptzsControlling(widget.cameraIndexCode, 1, "UP", widget.speed);
  }

  void _left() async {
    await HikApi.ptzsControlling(
        widget.cameraIndexCode, 0, "LEFT", widget.speed);
    await Future.delayed(const Duration(milliseconds: 100));
    await HikApi.ptzsControlling(
        widget.cameraIndexCode, 1, "LEFT", widget.speed);
  }

  void _down() async {
    await HikApi.ptzsControlling(
        widget.cameraIndexCode, 0, "DOWN", widget.speed);
    await Future.delayed(const Duration(milliseconds: 100));
    await HikApi.ptzsControlling(
        widget.cameraIndexCode, 1, "DOWN", widget.speed);
  }

  void _right() async {
    await HikApi.ptzsControlling(
        widget.cameraIndexCode, 0, "RIGHT", widget.speed);
    await Future.delayed(const Duration(milliseconds: 100));
    await HikApi.ptzsControlling(
        widget.cameraIndexCode, 1, "RIGHT", widget.speed);
  }
}
