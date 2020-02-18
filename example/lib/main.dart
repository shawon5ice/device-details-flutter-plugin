import 'package:flutter/material.dart';
import 'dart:async';
import 'package:device_details_plugin/device_details_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _androidInfo = {};

  @override
  void initState() {
    super.initState();
    _getAndroidInfo();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _getAndroidInfo() async {
    var androidInfo = await DeviceDetailsPlugin().getAndroidInfo();
    print(androidInfo);
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {
      _androidInfo = androidInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: _androidInfo.isEmpty ? CircularProgressIndicator() : _showInfo()
      ),
    );
  }

  _showInfo() {
    if(_androidInfo['error'] != null) {
      return Text('Failed to get information');
    } else {
      return Column(
        children: <Widget>[
          Text("osApiLevel: ${_androidInfo['osVersion']}"),
          Text("totalInternalStorage: ${_androidInfo['totalInternalStorage']}"),
          Text("freeInternalStorage: ${_androidInfo['freeInternalStorage']}"),
          Text("mobileNetwork: ${_androidInfo['mobileNetwork']}"),
          Text("totalRamSize: ${_androidInfo['totalRamSize']}"),
          Text("freeRamSize: ${_androidInfo['freeRamSize']}"),
          Text("screenSize: ${_androidInfo['osApiLevel']}"),
          Text("dateAndTime: ${_androidInfo['dateAndTime']}"),
          Text("manufacturer: ${_androidInfo['manufacturer']}"),
        ],
      );
    }
  }
}
