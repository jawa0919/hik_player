/*
 * @FilePath     : /hik_player/lib/hik_controller.dart
 * @Date         : 2021-10-27 09:22:21
 * @Author       : jawa0919 <jawa0919@163.com>
 * @Description  : HikController
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum HikStatus {
  IDLE, //闲置状态
  LOADING, //加载中状态
  SUCCESS, //播放成功
  STOPPING, //暂时停止播放
  FAILED, //播放失败
  EXCEPTION, //播放过程中出现异常
  FINISH, //回放结束
}
typedef HikControllerCallback = void Function(HikController controller);
typedef HikStatusCallback = void Function(HikStatus status);

class HikController extends ChangeNotifier {
  late MethodChannel _channel;
  HikStatusCallback? onHikStatusCallback;

  HikController.init(int id) {
    _channel = MethodChannel('hik_controller_$id');
    _channel.setMethodCallHandler((methodCall) async {
      switch (methodCall.method) {
        case "onPlayerStatusCallback":
        case "onTalkStatusCallback":
          int status = methodCall.arguments["status"] ?? 0;
          onHikStatusCallback?.call(HikStatus.values[status]);
          break;
        default:
      }
    });
  }

  ///开始预览
  ///预览开始前,需要设置播放器状态回调[setStatusCallback]
  ///liveRtspUrl 预览地址
  Future<dynamic> startRealPlay(String liveRtspUrl) async {
    return await _channel.invokeMethod('startRealPlay', <String, dynamic>{
      "url": liveRtspUrl,
    });
  }

  ///码流平滑切换
  ///需注意该方法仅在Android平台上生效,IOS不支持
  ///必须预览成功后才可调用
  ///liveRtspUrl 预览地址
  Future<dynamic> changeStream(String liveRtspUrl) async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod('changeStream', <String, dynamic>{
        "url": liveRtspUrl,
      });
    }
  }

  ///开始回放
  ///回放开始前,需要设置播放器状态回调[setStatusCallback]
  ///startTime 开始时间 格式为 yyyy-MMdd'T'HH:mm:ss.SSSZ
  ///stopTime 结束时间 格式为 yyyy-MMdd'T'HH:mm:ss.SSSZ
  Future<dynamic> startPlayback(
    String liveRtspUrl,
    String startTime,
    String stopTime,
  ) async {
    //ios设备需要将时间转为时间戳
    if (Platform.isIOS) {
      DateTime start = DateTime.parse(startTime);
      DateTime end = DateTime.parse(stopTime);
      startTime = (start.millisecondsSinceEpoch / 1000).toString();
      stopTime = (end.millisecondsSinceEpoch / 1000).toString();
    }
    return await _channel.invokeMethod('startPlayback', <String, dynamic>{
      "url": liveRtspUrl,
      "startTime": startTime,
      "stopTime": stopTime,
    });
  }

  ///按绝对时间回放定位
  ///seekTime 定位时间  格式为 yyyy-MMdd'T'HH:mm:ss.SSSZ
  Future<dynamic> seekAbsPlayback(String seekTime) async {
    //ios设备需要将时间转为时间戳
    if (Platform.isIOS) {
      DateTime seek = DateTime.parse(seekTime);
      seekTime = (seek.millisecondsSinceEpoch / 1000).toString();
    }
    return await _channel.invokeMethod('seekAbsPlayback', <String, dynamic>{
      "seekTime": seekTime,
    });
  }

  ///查询当前播放时间戳接口
  Future<dynamic> getOSDTime() async {
    Map? ret = await _channel.invokeMethod('getOSDTime');
    if (Platform.isIOS) {
      String? time = ret!['ret'];
      if ("-1" != time) {
        return DateTime.parse(time!);
      }
    } else if (Platform.isAndroid) {
      int time = ret!['ret'];
      if (time > 0) {
        return DateTime.fromMillisecondsSinceEpoch(time);
      }
    }
    return;
  }

  ///暂停回放
  Future<dynamic> pause() async {
    return await _channel.invokeMethod('pause');
  }

  ///恢复回放
  Future<dynamic> resume() async {
    return await _channel.invokeMethod('resume');
  }

  ///停止播放,包括预览和回放
  Future<dynamic> stopPlay() async {
    return await _channel.invokeMethod('stopPlay');
  }

  ///开启语音对讲
  ///语音开始前,需要设置播放器状态回调[setStatusCallback]
  ///liveRtspUrl 预览地址
  Future<dynamic> startVoiceTalk(String liveRtspUrl) async {
    return await _channel.invokeMethod('startVoiceTalk', <String, dynamic>{
      "url": liveRtspUrl,
    });
  }

  ///关闭语音对讲
  Future<dynamic> stopVoiceTalk() async {
    return await _channel.invokeMethod('stopVoiceTalk');
  }

  ///预览/回放 抓图
  ///必须预览/回放成功后才可调用
  ///bitmapPath 图片本地存储路径
  Future<dynamic> capturePicture(String bitmapPath) async {
    return await _channel.invokeMethod('capturePicture', <String, dynamic>{
      "path": bitmapPath,
    });
  }

  ///开启本地录像
  ///必须预览/回放成功后才可调用
  ///mediaFilePath 视频本地存储路径
  Future<dynamic> startRecord(String mediaFilePath) async {
    return await _channel.invokeMethod('startRecord', <String, dynamic>{
      "path": mediaFilePath,
    });
  }

  ///关闭本地录像
  ///必须预览/回放成功后才可调用
  Future<dynamic> stopRecord() async {
    return await _channel.invokeMethod('stopRecord');
  }

  ///声音控制
  ///必须预览/回放成功后才可调用
  Future<dynamic> enableSound(bool enable) async {
    return await _channel.invokeMethod('enableSound', <String, dynamic>{
      "enable": enable,
    });
  }

  ///生命周期回调
  ///注意:APP前后台切换时 华为手机 上不会回调生命周期方法，例如：华为P20，可以在这里手动调用
  Future<dynamic> onResume() async {
    return await _channel.invokeMethod('onResume');
  }

  ///生命周期回调
  ///注意:APP前后台切换时 华为手机 上不会回调生命周期方法，例如：华为P20，可以在这里手动调用
  Future<dynamic> onPause() async {
    return await _channel.invokeMethod('onPause');
  }

  ///设置播放器回调监听
  ///该回调全局只需设置一次即可
  void setHikStatusCallback(HikStatusCallback? callback) {
    onHikStatusCallback = callback;
  }
}
