import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mytube/download.dart';
import 'package:video_player/video_player.dart';
import 'package:mytube/storage.dart';
import 'dart:async';

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

  void alert(msg) {
    AlertDialog dialog = AlertDialog(
      backgroundColor: Colors.yellow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      content: Row(
        children: <Widget>[
          Icon(
            Icons.warning,
            color: Colors.red,
            size: 30,
          ),
          Padding(padding: EdgeInsets.only(right: 10)),
          Text(msg,
            style: TextStyle(
              color: Colors.red,
              fontSize: 30,
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

    //print("in alert()");
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    String url = await Storage.getString("url");
    print("MyTube.url: $url");
    try{
      if(url == this.widget.url) {
        download.fileName = await Storage.getString("fileName");
        download.title = await Storage.getString("title");
        download.author = await Storage.getString("author");
        download.duration = Duration(milliseconds: await Storage.getInt("duration"));
        processing = 100;
        setState(() { });
      } else {
        await download.getVideo(this.widget.url);
        Storage.setInt("position", 0);
        await download.execute(onProcessing: (int process){
          processing = process;
          if(process == 100) {
            Storage.setString("url", this.widget.url);
            Storage.setString("fileName", download.fileName);
            Storage.setString("title", download.title);
            Storage.setString("author", download.author);
            Storage.setInt("duration", download.duration.inMilliseconds);
          }
          setState(() { });
        });
      }
      print("MyTube.player.download: ${download.fileName}");
    } catch(e) {
      alert(e.toString());
      print("MyTube.player: ${e.toString()}");
    }
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
    return Material(
      child: Container(
        decoration: new BoxDecoration(color: Colors.white),
        padding: EdgeInsets.all(0.0), //容器内补白
        width: double.infinity,
        // child: webview()
        child: download == null || download.title.length == 0 ? loading() : step2()
      )
    );
  }

  Widget loading() {
    return new Center( //保证控件居中效果
      child: new SizedBox(
        width: 250.0,
        height: 120.0,
        child: new Container(
          decoration: ShapeDecoration(
            color: Color(0xffffffff),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
          ),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new CircularProgressIndicator(),
              // new Padding(
              //   padding: const EdgeInsets.only(top: 20.0),
              //   child: "loading",
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget step2(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(processing == 100)
          PlayerControler(fileName: download.fileName),
          // Expanded(flex: 1,  child: PlayerControler(fileName: download.fileName)),
        Text(download.title,
          textAlign: TextAlign.left,
          style: new TextStyle(
            color: Colors.blue,
            fontSize: 20,
          )
        ),
        if(download.author.length > 0)
          Text("作者：" + download.author,
            textAlign: TextAlign.left,
            style: new TextStyle(
              // color: Colors.blue,
              fontSize: 20,
            )
          ),
        if(processing < 100)
          Text("時間：" + download.duration.toString().replaceAll(".000000", ""),
            textAlign: TextAlign.left,
            style: new TextStyle(
              // color: Colors.blue,
              fontSize: 20,
            )
          ),
        if(processing < 100)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(height: 30,),
              LinearProgressIndicator(  
                  // backgroundColor: Colors.cyanAccent,  
                  // valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),  
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(Colors.blue),
                  value: processing.toDouble() / 100,  
                ),
                Text(processing.toString(),
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                    // color: Colors.blue,
                    fontSize: 20,
                  )
                ),
            ]
          ),
      ]
    );
  }
}

class PlayerControler extends StatefulWidget {
  final String fileName;

  PlayerControler({Key? key, required this.fileName}) : super(key: key);

  @override
  _PlayerControlerState createState() => _PlayerControlerState();
}


class _PlayerControlerState extends State<PlayerControler> with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  Duration _duration = Duration(seconds: 0);
  Duration _position = Duration(seconds: 0);

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController
    .file(File("file://" + widget.fileName))
    ..addListener(() {
      // final bool isPlaying = _controller.value.isPlaying;
      // if (isPlaying != _isPlaying) {
      //   setState(() {
      //     _isPlaying = isPlaying;
      //   });
      // } 
      Timer.periodic(Duration(seconds: 1), (timer) {
        this.setState((){
          _position = _controller!.value.position;
          if(_position.inSeconds == _duration.inSeconds) {
            Storage.setInt("position", 0);
          } else if(_position.inSeconds > 0 && _position.inSeconds % 10 == 0) {
            Storage.setInt("position", _position.inSeconds);
          }
        });
      });
      setState(() {
        _duration = _controller!.value.duration;
      });
        // _duration?.compareTo(_position) == 0 || _duration?.compareTo(_position) == -1 ? this.setState((){
        //   _isEnd = true;
        // }) : this.setState((){
        //   _isEnd = false;
        // });
    })
    ..initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      setState(() async  {
        int position = await Storage.getInt("position");
        if(position > 0)
          _controller!.seekTo(Duration(seconds: position));
        print("MyTube.position 1: $position");
        
        _controller!.play();
      });
    });
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state)  {
    // /Users/jimc/.pub-cache/hosted/pub.dartlang.org/video_player-2.1.14/lib/video_player.dart
    // 要 mark 不然 pause
    print("MyTube.didChangeAppLifecycleState: $state");
    // switch (state) {
    //   case AppLifecycleState.paused:
    //     // _controller!.pause();
    //     _controller!.play();
    //     break;
    //   case AppLifecycleState.resumed:
    //     // _controller!.play();
    //     break;
    //   default:
    // }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
    _controller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    // print("MyTube.screen => height: $height, width: $width");
    return Column(children: [
      Container(
        width: width > 600 ? 600 : width,
        child: _controller!.value.isInitialized
          ? AspectRatio(aspectRatio: _controller!.value.aspectRatio, child: VideoPlayer(_controller!))
          : Container(),
      ),
      
      Row(
        children: [

        ]
      ),
      Ink(
        decoration: ShapeDecoration(
          color: Colors.black,
          shape: CircleBorder(),
        ),
        child: IconButton(
          icon: Icon(_controller!.value.isPlaying ? Icons.pause : Icons.play_arrow),
          // color: Colors.white,
          onPressed: () {
            setState(() {
              _controller!.value.isPlaying
                  ? _controller!.pause()
                  : _controller!.play();
            });
          },
        ),
      ),
      Text('Duration ${_duration.toString()}'),
      Text('Position ${_position.toString()}'),
      // if(_duration.inSeconds > 0)
        Slider(
          value: _position.inSeconds.toDouble(),
          min: 0,
          max: _duration.inSeconds.toDouble(),
          // label: _position.inSeconds.toDouble().round().toString(),
          label: _position.toString(),
          onChanged: (double value) {
            setState(() {
              _controller!.seekTo(Duration(seconds: value.toInt()));
            });
            
            print("MyTube.onChanged: $value");
          },
          // onChangeStart: (value) {
          //   print("MyTube.onChangeStart: $value");
          // },
          // onChangeEnd: (value) {
          //   print("MyTube.onChangeEnd: $value");
          // },
        )
    ]);
  }

}
