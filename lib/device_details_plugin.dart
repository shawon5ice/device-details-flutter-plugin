import 'dart:async';

import 'package:flutter/services.dart';

class DeviceDetailsPlugin {
  static const MethodChannel _channel =
      const MethodChannel('device_details_plugin');

  var result = {};

  Future<Map<dynamic, dynamic>> getAndroidInfo() async {
    try {
      result = await _channel.invokeMethod("getAndroidInfo");
    } on PlatformException catch (e) {
      result = {'error': true, 'code': e.code, 'message': e.message};
    }
    print(result);
    return result;
  }

  Future<Map<dynamic, dynamic>> getiOSInfo() async {
    try {
      result = await _channel.invokeMethod("getiOSInfo");
    } on PlatformException catch (e) {
      result = {'error': true, 'code': e.code, 'message': e.message};
    }
    print(result);
    return result;
  }
}
