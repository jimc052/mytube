import 'package:flutter/material.dart';
import 'package:mytube/system/history.dart';
import 'package:mytube/video/player.dart';
import 'package:mytube/video/browser.dart';
import 'package:mytube/system/system.dart';
import 'package:mytube/youtube.dart';
import 'dart:ui'; 
import 'dart:async';
import 'dart:io';
import 'dart:convert';

class Video extends StatefulWidget {
  final String url;
  Video({Key? key, required this.url}) : super(key: key){
    // print("MyTube.Video.url: " + this.url);
    // print("${Youtube.host}");
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
    // alert(context, "test",
    //         actions: [{"text": "確定", "onPressed": (){
    //           Navigator.pop(context);
    //         }}]
    //       );
    
    String url = await Storage.getString("url");
    String fileName = await Storage.getString("fileName");
    var file = File(fileName);
    try{
      if(url == this.widget.url && file.existsSync()) {
        
      } else {
        // var videoKey = this.widget.url.replaceAll("https://m.youtube.com/watch?v=", "");
        // String s = await Storage.getString("historys");
        // Map<String, dynamic> historys = {};
        // if(s.length > 0) {
        //   historys = jsonDecode(s);
        // }
        // print("MyTube.historys: ${historys}");
        // if(historys.containsKey(videoKey)) {
        //   History history = historys[videoKey];
        //   alert(context, "${history.title}：\n曾於 ${history.date} 觀賞，\n${history.position}",
        //     actions: [{"text": "確定", "onPressed": (){
        //       Navigator.pop(context);
        //     }}]
        //   );
        // }
      }
    } catch(e) {
      print("MyTube.player: $e");
      alert(context, e.toString());
    }
    // Navigator.pop(context);
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
          // if(local == 1)
          //   IconButton( // 另存新檔
          //     icon: Icon(
          //       Icons.file_copy,
          //       color: Colors.white,
          //     ),
          //     onPressed: () {
          //       fileSave(context, url: this.widget.url); 
          //     }
          //   ),
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
}