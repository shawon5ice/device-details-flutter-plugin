import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:device_details_plugin/device_details_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _deviceInfo = {};

  @override
  void initState() {
    super.initState();
    getDeviceInfo();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> getDeviceInfo() async {
    var deviceInfo = Platform.isIOS ? await DeviceDetailsPlugin().getiOSInfo():
    await DeviceDetailsPlugin().getAndroidInfo();
    print(deviceInfo);
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {
      _deviceInfo = deviceInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: _deviceInfo.isEmpty ? CircularProgressIndicator() : _showInfo()
      ),
    );
  }

  _showInfo() {
    if(_deviceInfo['error'] != null) {
      return Text('Failed to get information');
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text("osApiLevel: ${_deviceInfo['osVersion']}"),
          Text("totalInternalStorage: ${_deviceInfo['totalInternalStorage']}"),
          Text("freeInternalStorage: ${_deviceInfo['freeInternalStorage']}"),
          Text("mobileNetwork: ${_deviceInfo['mobileNetwork']}"),
          Text("totalRamSize: ${_deviceInfo['totalRamSize']}"),
          Text("freeRamSize: ${_deviceInfo['freeRamSize']}"),
          Text("screenSize: ${_deviceInfo['screenSize']}"),
          Text("dateAndTime: ${_deviceInfo['dateAndTime']}"),
          Text("manufacturer: ${_deviceInfo['manufacturer']}"),
        ],
      );
    }
  }
}
