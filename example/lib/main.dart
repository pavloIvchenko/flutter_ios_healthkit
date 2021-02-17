import 'package:flutter/material.dart';

import 'package:ios_healthkit/ios_healthkit.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  dynamic _basicHealthString;

  @override
  void initState() {
    super.initState();
    _requestAppleFIHR();
  }

  _getAllData() async {
    var categories = ['immunization', 'labResults', 'vitalSigns', 'procedures', 'activity', 'steps', 'workouts', 'weight', 'sleepDetails', 'restingEnergy', 'activitySummary'];
    print(categories);
    var endDate = new DateTime.now();
    var startDate =  endDate.subtract(Duration(minutes: 30));
    var data = await IosHealthkit().getHealthKitData(categories, startDate, endDate);
    print('Get data result:' + data.toString());
    setState(() {
    _basicHealthString = data.toString();
    });
  }

  _requestAppleFIHR() async {
    print("Request start");
    var categories = ['immunization', 'labResults', 'vitalSigns', 'procedures', 'activity', 'steps', 'sleep', 'weight', 'workouts', 'heartRate', 'restingHeartRate', 'heartRateVariability', 'walkingHeartRate', 'restingEnergy', 'activitySummary'];
    dynamic authorizationResult = await IosHealthkit.requestAuthorization(categories);
    print('Authorization result:' + authorizationResult);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text('Authorize'),
              onPressed: () {
                print("Authorize");
                _requestAppleFIHR();
              },
            ),
            RaisedButton(
              child: Text('Get all data'),
              onPressed: () {
                _getAllData();
              },
            ),
            Text('FIHR Data: $_basicHealthString\n'),
          ],
        )),
      ),
    );
  }
}
