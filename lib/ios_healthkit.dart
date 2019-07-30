import 'dart:async';

import 'package:flutter/services.dart';

class IosHealthkit {
  static const MethodChannel _channel =
      const MethodChannel('ios_healthkit');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<dynamic> get getMedicalRecords async {
    return await _channel.invokeMethod('getMedicalRecords');
  }

  static Future<dynamic> get getActivityData async {
    return await _channel.invokeMethod('getActivityData');
  }

  static Future<dynamic> get getStepsData async {
    return await _channel.invokeMethod('getStepsData');
  }

  static Future<dynamic> get getSleepData async {
    return await _channel.invokeMethod('getSleepData');
  }

  static Future<dynamic> get requestAuthorization async {
    print("Call in dart plugin");
    return await _channel.invokeMethod('requestAuthorization');
  }
}




