import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:package_info/package_info.dart';

import 'home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MaterialApp(home: UserInformation()),
    );
  }
}

class UserInformation extends StatefulWidget {
  @override
  _UserInformationState createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('manage_version').snapshots();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream: _usersStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            } else {
              return new ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  print(data['version']);
                  _showMyDialog(context, int.parse(data['version']));

                  return new ListTile(
                    title: new Text(data['message_title']),
                    subtitle: new Text(data['version'],

                    ),
                    trailing: TextButton(child: Text("Home Screen"),onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
                    },),
                  );
                }).toList(),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _showMyDialog(context, serverVersion) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    print("version ${int.parse(version[0])}");
    int localVersion = int.parse(version[0]);

    if (localVersion < serverVersion) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('title'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'Do you want to update from : $version to new version: $serverVersion'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('later'),
                onPressed: () {
                  Navigator.pop(context);

                  // Navigator.of(context, rootNavigator: true).pop('dialog');
                },
              ),
              TextButton(
                child: const Text('Update'),
                onPressed: () {
                  if (Platform.isAndroid) {
                    LaunchReview.launch(
                        androidAppId: "com.iyaffle.rangoli",
                        iOSAppId: "585027354");
                  }
                  LaunchReview.launch(
                      writeReview: false, iOSAppId: "585027354");
                  // Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      return;
    }
  }
}
