import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:mytube/player.dart';
import 'package:mytube/storage.dart';
import 'package:mytube/browser.dart';
import 'dart:ui'; 
import 'dart:async';

class Video extends StatefulWidget {
  final String url;
  Video({Key? key, required this.url}) : super(key: key){
    // print("MyTube.Video.url: " + this.url);
  }

  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends State<Video> with WidgetsBindingObserver {
  int local = -1;
  var timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    local = await Storage.getInt("isLocal");
    this.setState(() {});
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state)  {
    switch (state) {
      case AppLifecycleState.paused:
        if(local != 1) {
          timer = Timer(Duration(minutes: 20), () { // broswer.dart 要 pause
            Navigator.pop(context);
          });          
        }
        break;
      case AppLifecycleState.resumed:
        if(timer != null) timer.cancel();
        break;
      default:
    }
  }
  @override
  dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
  @override
  void reassemble() async {
    super.reassemble();
    local = -1; this.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.expand(),
      child: Stack(
        alignment:Alignment.center , //指定未定位或部分定位widget的对齐方式
        children: <Widget>[
          Container(
            decoration: new BoxDecoration(color: Colors.transparent),
            width: double.infinity,
            child: local == -1 ? null : (local == 1  
              ? Player(url: this.widget.url) 
              : Browser(url: this.widget.url))
          ),
          if(local > -1)
            Positioned(
              bottom: 10.0,
              right: 10.0,
              child: MaterialButton(
                shape: CircleBorder(),
                color: Colors.blue,
                padding: EdgeInsets.all(15),
                onPressed: () async {
                  local = local == 1 ? 0 : 1;
                  await Storage.setInt("isLocal", local);
                  setState(()  { });
                },
                child: Icon( local == 0 ? Icons.vertical_align_bottom_sharp : Icons.wb_cloudy_sharp, size: 30, color: Colors.white,
                ),
              )
            ) 
          ,
        ],
      ),
    );
  }
}