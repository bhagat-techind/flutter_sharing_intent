import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription _intentDataStreamSubscription;
  List<SharedFile>? list;

  @override
  void initState() {
    initSharingListener();

    super.initState();
  }

  initSharingListener() {
    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = FlutterSharingIntent.instance
        .getMediaStream()
        .listen((List<SharedFile> value) {
      setState(() {
        list = value;
      });
      if (kDebugMode) {
        print(" Shared: getMediaStream ${value.map((f) => f.value).join(",")}");
      }
    }, onError: (err) {
      if (kDebugMode) {
        print("Shared: getIntentDataStream error: $err");
      }
    });

    // For sharing images coming from outside the app while the app is closed
    FlutterSharingIntent.instance
        .getInitialSharing()
        .then((List<SharedFile> value) {
      if (kDebugMode) {
        print(
            "Shared: getInitialMedia => ${value.map((f) => f.value).join(",")}");
      }
      setState(() {
        list = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Text('Sharing data: \n${list?.join("\n\n")}\n')),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }
}
