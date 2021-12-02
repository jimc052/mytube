import 'package:flutter/material.dart';
import 'package:mytube/system/history.dart';
import 'package:mytube/video/player.dart';
import 'package:mytube/video/browser.dart';
import 'package:mytube/system/system.dart';
import 'package:mytube/download.dart';
import 'package:mytube/system/playlist.dart';
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
  Map<String, dynamic> playItem = {};
  String folder = "";
  var timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    String key = Download.parselKey(this.widget.url);
    Playlist playlist = Playlist();
    await playlist.initial();
    Map<String, dynamic>? _playItem = playlist.search(key);
    if(_playItem == null) {
      local = await Storage.getInt("isLocal");
      await changeSource();
    } else {
      playItem = _playItem["item"];
      folder = _playItem["key"];
      local = 1;
    }

    this.setState((){});
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
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_sharp,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('MyTube'),
          actions: [],
        ),
        body: local == -1 ? null : (local == 1  
          ? Player(url: this.widget.url, folder: folder, playItem: playItem) 
          : Browser(url: this.widget.url)
        ),
        floatingActionButton: playItem["key"] is String && playItem["fileName"] is String
          ? Container()
          : FloatingActionButton(
          onPressed: () async {
            local = local == 1 ? 0 : 1;
            await Storage.setInt("isLocal", local);
            await changeSource();
            setState((){ });
          },
          child: local == -1 ? Container() : Icon(local == 0 ? Icons.vertical_align_bottom_sharp : Icons.wb_cloudy_sharp, size: 30, color: Colors.white,),
        )
      )
    );
  }

  changeSource() async {
    playItem = {};
    if(local == 1) {
      String url = await Storage.getString("url");
      String fileName = await Storage.getString("fileName");
      var file = File(fileName);
      try{
        if(url == this.widget.url && file.existsSync()) {
          playItem["fileName"] = await Storage.getString("fileName");
          playItem["title"] = await Storage.getString("title");
          playItem["author"] = await Storage.getString("author");
          playItem["mb"] = await Storage.getString("mb");
          playItem["duration"] = Duration(milliseconds: await Storage.getInt("duration"));
        } else {
        }
      } catch(e) {

      }
    }
  }
}