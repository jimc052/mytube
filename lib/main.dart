import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io' show Platform;
import 'package:mytube/home.dart';
import 'package:mytube/mac.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Tube',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Platform.isAndroid ? Home() : Mac(),

    );
  }
}
