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
  Download download = new Download();
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await download.getVideo(this.widget.url);
    await download.execute(onProcessing: (int process){
      processing = process;
      setState(() { });
    });
    print("下載完了...............");
  }
  @override
  dispose() {
    super.dispose();
    download.stop = true;
  }
  @override
  void reassemble() async {
    super.reassemble();
  }

  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(color: Colors.white),
      width: double.infinity,
      child: Column(children: [
        Text(download.title),
        Text(download.author),
        Text(download.duration.inSeconds.toString()),
        Text(processing.toString())
      ],)
    );
  }
}
