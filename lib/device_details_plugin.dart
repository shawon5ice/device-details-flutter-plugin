import 'dart:async';
import 'dart:io';


import 'package:flutter/services.dart';

const MethodChannel _channel = const MethodChannel('device_details_plugin');

class DeviceDetailsPlugin {
  /// The app name. `CFBundleDisplayName` on iOS, `application/label` on Android.
  final String appName;

  /// The package name. `bundleIdentifier` on iOS, `getPackageName` on Android.
  final String packageName;

  /// The package version. `CFBundleShortVersionString` on iOS, `versionName` on Android.
  final String version;

  /// The build number. `CFBundleVersion` on iOS, `versionCode` on Android.
  final String buildNumber;

  final String flutterAppVersion;

  final String osVersion;

  final String totalInternalStorage;

  final String freeInternalStorage;

  final String networkOperator;

  final String totalRAMSize;

  final String freeRAMSize;

  final String screenSizeInInches;

  final String manufacturer;

  final String deviceId;

  final String currentDateTime;

  DeviceDetailsPlugin({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    required this.flutterAppVersion,
    required this.osVersion,
    required this.totalInternalStorage,
    required this.freeInternalStorage,
    required this.networkOperator,
    required this.totalRAMSize,
    required this.freeRAMSize,
    required this.screenSizeInInches,
    required this.manufacturer,
    required this.deviceId,
    required this.currentDateTime
  });

  static DeviceDetailsPlugin? _deviceDetailsPlugin;

  static Future<DeviceDetailsPlugin?> getDeviceInfo() async {
    try {
      final Map<dynamic, dynamic> map = Platform.isIOS ?
      await _channel.invokeMethod("getiOSInfo") :
      await _channel.invokeMethod("getAndroidInfo");
      _deviceDetailsPlugin = DeviceDetailsPlugin(
        appName: map["appName"],
        packageName: map["packageName"],
        version: map["version"],
        buildNumber: map["buildNumber"],
        flutterAppVersion: map["flutterAppVersion"],
        osVersion: map['osVersion'],
        totalInternalStorage: map['totalInternalStorage'],
        freeInternalStorage: map['freeInternalStorage'],
        networkOperator: map['mobileNetwork'],
        totalRAMSize: map['totalRamSize'],
        freeRAMSize: map['freeRamSize'],
        screenSizeInInches: map['screenSize'],
        manufacturer: map['manufacturer'],
        deviceId: map['deviceId'],
        currentDateTime: map['dateAndTime']
      );
      print(_deviceDetailsPlugin?.deviceId);
    } on PlatformException catch (e) {
      print('DeviceDetailsPlugin error: ${true}, code: ${e.code}, message: ${e.message}');
    }
    return _deviceDetailsPlugin;
  }
}
