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
    // local = 1; this.setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_sharp,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('MyTube'),
        actions: [
          IconButton( // 另存新檔
            icon: Icon(
              Icons.file_copy, // more_horiz
              color: Colors.white,
            ),
            onPressed: () {
              print('MyTube.file_copy');
              alert("還沒有寫，另存新檔");
            }
          ),
        ],
      ),
      body: local == -1 ? null : (local == 1  
        ? Player(url: this.widget.url) 
        : Browser(url: this.widget.url)
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          local = local == 1 ? 0 : 1;
          await Storage.setInt("isLocal", local);
          setState(()  { });
        },
        child: local == -1 ? Container() : Icon(local == 0 ? Icons.vertical_align_bottom_sharp : Icons.wb_cloudy_sharp, size: 30, color: Colors.white,),
      )
    );
  }

  void alert(msg) {
    AlertDialog dialog = AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(0)),
      ),
      content: Row(
        children: <Widget>[
          Icon(
            Icons.warning,
            color: Colors.red,
            size: 20,
          ),
          Padding(padding: EdgeInsets.only(right: 10)),
          Text(msg,
            style: TextStyle(
              color: Colors.red,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: Text(
            "CLOSE",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );

    showDialog(
      barrierDismissible: false,
      context: context, 
      builder: (BuildContext context) => dialog,
    );
  }
}