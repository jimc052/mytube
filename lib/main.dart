import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:mytube/home.dart';

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
      home: Home() //Platform.isAndroid ? Home() : Mac(),
    );
  }
}
