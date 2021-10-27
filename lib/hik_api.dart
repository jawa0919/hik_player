/*
 * @FilePath     : /hik_player/lib/hik_api.dart
 * @Date         : 2021-08-17 16:28:42
 * @Author       : jawa0919 <jawa0919@163.com>
 * @Description  : 
 */

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

class HikApi {
  static String _artemisPath = "";
  static String _host = "";
  static String _appKey = "";
  static String _appSecret = "";

  static late Client _sslClient;

  static void init(String host, String appKey, String appSecret,
      {String artemisPath = "/artemis"}) {
    _host = host;
    _appKey = appKey;
    _appSecret = appSecret;
    _artemisPath = artemisPath;
    _sslClient = _initClient();
  }

  /// See: <https://open.hikvision.com/docs/docId?productId=083bafe42ff34af7842aa3d6d8fa47f6&curNodeId=c898422395fa4aac840d40d754823eba#d7cd598b/>
  static Map<String, String> xcakeyHeaders(String url) {
    final list = [
      "POST\n",
      "*/*\n",
      "application/json;charset=UTF-8\n",
      "x-ca-key:$_appKey\n",
      url
    ];
    final hmac = Hmac(sha256, utf8.encode(_appSecret));
    final digest = hmac.convert(utf8.encode(list.join()));
    return {
      "Accept": "*/*",
      "Content-Type": "application/json;charset=UTF-8",
      "X-Ca-Key": _appKey,
      "X-Ca-Signature": base64Encode(digest.bytes),
      "X-Ca-Signature-Headers": "x-ca-key",
    };
  }

  static Client _initClient() {
    final httpClient = HttpClient();
    httpClient.badCertificateCallback = (cert, host, port) => true;
    final _ioClient = IOClient(httpClient);
    return _ioClient;
  }

  /// See: <https://open.hikvision.com/docs/docId?productId=083bafe42ff34af7842aa3d6d8fa47f6&curNodeId=979ab5f343114ad6a96f2d46d8cc26c9#b5bd6fd9/>
  static Future<String> previewURLs(
    String cameraIndexCode, {
    int? streamType,
    String? protocol,
    int? transmode,
    String? expand,
    String? streamform,
  }) async {
    if (cameraIndexCode.isEmpty) throw ArgumentError("cameraIndexCode.isEmpty");
    String url = "$_artemisPath/api/video/v2/cameras/previewURLs";
    final headers = xcakeyHeaders(url);
    final uri = Uri.parse('$_host$url');
    final response = await _sslClient.post(
      uri,
      headers: headers,
      body: jsonEncode({"cameraIndexCode": cameraIndexCode}),
    );
    final data = jsonDecode(response.body);
    return data['data']['url'];
  }

  /// See: <https://open.hikvision.com/docs/docId?productId=083bafe42ff34af7842aa3d6d8fa47f6&curNodeId=979ab5f343114ad6a96f2d46d8cc26c9#d4555994/>
  static Future manualCapture(String cameraIndexCode) async {
    if (cameraIndexCode.isEmpty) throw ArgumentError("cameraIndexCode.isEmpty");
    String url = "$_artemisPath/api/video/v1/manualCapture";
    final headers = xcakeyHeaders(url);
    final uri = Uri.parse('$_host$url');
    final body = {
      "cameraIndexCode": cameraIndexCode,
    };
    final response = await _sslClient.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    final data = jsonDecode(response.body);
    return data;
  }

  /// See: <https://open.hikvision.com/docs/docId?productId=083bafe42ff34af7842aa3d6d8fa47f6&curNodeId=979ab5f343114ad6a96f2d46d8cc26c9#e6643a97/>
  static Future ptzsControlling(
    String cameraIndexCode,
    int action,
    String command,
    int speed,
  ) async {
    if (cameraIndexCode.isEmpty) throw ArgumentError("cameraIndexCode.isEmpty");
    String url = "$_artemisPath/api/video/v1/ptzs/controlling";
    final headers = xcakeyHeaders(url);
    final uri = Uri.parse('$_host$url');
    final body = {
      "cameraIndexCode": cameraIndexCode,
      "action": action,
      "command": command,
      "speed": speed,
    };
    final response = await _sslClient.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    final data = jsonDecode(response.body);
    return data;
  }
}
