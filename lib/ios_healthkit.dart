import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class IosHealthkit {
  static const MethodChannel _channel = const MethodChannel('ios_healthkit');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String?> getMedicalRecords() async {
    return await _channel.invokeMethod('getMedicalRecords');
  }

  static Future<String?> getActivityTimeData(int startTime, int endTime) async {
    return await _channel.invokeMethod('getActivityTimeData', { 'startTime': startTime, 'endTime': endTime });
  }

  static Future<String?> getFullActivityData(int startTime, int endTime) async {
    return await _channel.invokeMethod('getFullActivityData', { 'startTime': startTime, 'endTime': endTime });
  }

  static Future<String?> getStepsData(int startTime, int endTime) async {
    return await _channel.invokeMethod('getStepsData', { 'startTime': startTime, 'endTime': endTime });
  }

  static Future<String?> getFlightsClimbed(int startTime, int endTime) async {
    return await _channel.invokeMethod('getFlightsClimbed', { 'startTime': startTime, 'endTime': endTime });
  }

  static Future<String?> getRestingEnergyData(int startTime, int endTime) async {
    return await _channel.invokeMethod('getRestingEnergyData', { 'startTime': startTime, 'endTime': endTime });
  }

  static Future<String?> getSleepData(int startTime, int endTime) async {
    return await _channel.invokeMethod('getSleepData', { 'startTime': startTime, 'endTime': endTime });
  }

  static Future<String?> getSleepDetails(int startTime, int endTime) async {
    return await _channel.invokeMethod('getSleepDetails', { 'startTime': startTime, 'endTime': endTime });
  }

  static Future<String?> getWeightData(int startTime, int endTime) async {
    return await _channel.invokeMethod('getWeightData', { 'startTime': startTime, 'endTime': endTime });
  }

  static Future<String?> getWorkoutsData(int startTime, int endTime) async {
    return await _channel.invokeMethod('getWorkoutsData', { 'startTime': startTime, 'endTime': endTime });
  }

  static Future<String?> getHeartRateData(int startTime, int endTime) async {
    return await _channel.invokeMethod('getHeartRateData', { 'startTime': startTime, 'endTime': endTime });
  }

  static Future<String?> getWalkingHeartRateData(int startTime, int endTime) async {
    return await _channel.invokeMethod('getWalkingHeartRateData', { 'startTime': startTime, 'endTime': endTime });
  }

  static Future<String?> getHeartRateVariability(int startTime, int endTime) async {
    return await _channel.invokeMethod('getHeartRateVariability', { 'startTime': startTime, 'endTime': endTime });
  }

  static Future<String?> getRestingHeartRateData(int startTime, int endTime) async {
    return await _channel.invokeMethod('getRestingHeartRateData', { 'startTime': startTime, 'endTime': endTime });
  }

  static Future<dynamic> requestAuthorization(List<String> categories) async {
    print("Call in dart plugin");
    return await _channel
        .invokeMethod('requestAuthorization', {'wantedCategories': categories});
  }

  getHealthKitData(List<String> categories, DateTime startDate, DateTime endDate) async {
    print('START DATE: $startDate');
    print('END DATE: $endDate');
    Duration dateDiff = endDate.difference(startDate);
    int weeksCount = dateDiff.inDays ~/ 7;
    int daysLeft = dateDiff.inDays % 7;
    if (daysLeft > 0 || weeksCount == 0) {
      weeksCount++;
    }
    print('Weeks count: $weeksCount');
    var weekData = [];
    for (var i = 0; i < weeksCount; i++ ) {
      if (i == 4) {
        break;
      }
      DateTime weekEnd = endDate.subtract(Duration(days: 7 * i));
      DateTime weekStart = weekEnd.subtract(Duration(days: 7));
      if (weekStart.isBefore(startDate)) {
        weekStart = startDate;
      }
      print('weekStart: ' + weekStart.toString());
      print('weekEnd: ' + weekEnd.toString());
      int weekStartStamp = weekStart.millisecondsSinceEpoch ~/ 1000;
      int weekEndStamp = weekEnd.millisecondsSinceEpoch ~/ 1000;
      int fourWeeksBeforeStamp = endDate.subtract(Duration(days: 28)).millisecondsSinceEpoch ~/ 1000;
      int todayStamp = endDate.millisecondsSinceEpoch ~/ 1000;
      Map collectedData = await retrieveDataByCategory(weekStartStamp, weekEndStamp, fourWeeksBeforeStamp, todayStamp, categories);
      weekData.add(collectedData);
    }
    print('RETURN WEEK DATA');
//    print(weekData);
    return weekData;
  }


  retrieveDataByCategory(int weekStartStamp, int weekEndStamp, int fourWeeksBeforeStamp, int todayStamp, List<String> categories) async {
    Map collectedData = {};
    for (String category in categories) {
      String? data;
      switch (category) {
        case 'activity':
          data = await getActivityTimeData(fourWeeksBeforeStamp, todayStamp);
          print('activityTime: $data');
          break;
        case 'activitySummary':
          data = await getFullActivityData(fourWeeksBeforeStamp, todayStamp);
          print('activitySummary: $data');
          break;
        case 'steps':
          data = await getStepsData(fourWeeksBeforeStamp, todayStamp);
          print('steps: $data');
          break;
        case 'flightsClimbed':
          data = await getFlightsClimbed(fourWeeksBeforeStamp, todayStamp);
          print('steps: $data');
          break;
        case 'restingEnergy':
          data = await getRestingEnergyData(fourWeeksBeforeStamp, todayStamp);
          print('getRestingEnergyData: $data');
          break;
        case 'sleep':
          data = await getSleepData(fourWeeksBeforeStamp, todayStamp);
          print('sleep: $data');
          break;
        case 'sleepDetails':
          data = await getSleepDetails(fourWeeksBeforeStamp, todayStamp);
          print('sleepDetails: $data');
          break;
        case 'weight':
          data = await getWeightData(weekStartStamp, weekEndStamp);
          print('weight: $data');
          break;
        case 'workouts':
          data = await getWorkoutsData(fourWeeksBeforeStamp, todayStamp);
          print('workouts: $data');
          break;
        case 'heartRate':
          data = await getHeartRateData(weekStartStamp, weekEndStamp);
          print('heartRate: $data');
          break;
        case 'restingHeartRate':
          data = await getRestingHeartRateData(weekStartStamp, weekEndStamp);
          print('restingHeartRate: $data');
          break;
        case 'heartRateVariability':
          data = await getHeartRateVariability(weekStartStamp, weekEndStamp);
          print('heartRateVariability: $data');
          break;
        case 'getWalkingHeartRateData':
          data = await getWalkingHeartRateData(weekStartStamp, weekEndStamp);
          print('getWalkingHeartRateData: $data');
          break;
        default:
          print('Skip key: $category');
      }
      print('Data: $data');
      if (data != null && data.length > 0) {
        collectedData[category] = json.decode(data);
      }
    }
    return collectedData;
  }

}


