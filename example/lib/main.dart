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

  _getUserMedicalRecords() async {
    var basicHealth = await IosHealthkit.getMedicalRecords;
    print('Get data result:' + basicHealth);
    setState(() {
      _basicHealthString = basicHealth.toString();
    });
  }

  _getUserActivity() async {
    var activity = await IosHealthkit.getActivityData;
    print('Get data result:' + activity);
    setState(() {
      _basicHealthString = activity.toString();
    });
  }

  _getUserStepsData() async {
    var steps = await IosHealthkit.getStepsData;
    print('Get data result:' + steps);
    setState(() {
      _basicHealthString = steps.toString();
    });
  }

  _getUserSleepData() async {
    var sleep = await IosHealthkit.getSleepData;
    print('Get data result:' + sleep);
    setState(() {
      _basicHealthString = sleep.toString();
    });
  }

  _requestAppleFIHR() async {
    print("Request start");
    dynamic authorizationResult = await IosHealthkit.requestAuthorization;
    print('Authorization result:' + authorizationResult);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
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
                child: Text('Get records'),
                onPressed: () {
                  _getUserMedicalRecords();
                },
              ),
              RaisedButton(
                child: Text('Get activity'),
                onPressed: () {
                  _getUserActivity();
                },
              ),
              RaisedButton(
                child: Text('Get steps data'),
                onPressed: () {
                  _getUserStepsData();
                },
              ),
              RaisedButton(
                child: Text('Get sleep data'),
                onPressed: () {
                  _getUserSleepData();
                },
              ),
              Text('FIHR Data: $_basicHealthString\n'),
            ],
          )
        ),
      ),
    );
  }
}
