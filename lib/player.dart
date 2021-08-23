import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mytube/download.dart';

class Player extends StatefulWidget {
  final String url;
  Player({Key? key, required this.url}) : super(key: key);

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  int processing = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await Download.execute(this.widget.url, onLoad: (dynamic voide){
      this.setState(() {
        
      });
      print("MyTube.Video.onLoad: $voide");
    }, onProcessing: (int process){
      processing = process;
      setState(() { });
    });
    print("下載完了...............");
  }
  @override
  dispose() {
    super.dispose();
  }
  @override
  void reassemble() async {
    super.reassemble();
  }

  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(color: Colors.white),
      child: Column(children: [
        Text(Download.title),
        Text(Download.author),
        Text(Download.duration.inSeconds.toString()),
        Text(processing.toString())
      ],)
    );
  }
}
