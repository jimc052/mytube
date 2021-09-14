import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mytube/download.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:mytube/system/system.dart';

class Player extends StatefulWidget {
  final String url;
  Player({Key? key, required this.url}) : super(key: key);

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  int processing = -1;
  Download download = new Download();
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    String url = await Storage.getString("url");
    url = ""; // for test................
    print("MyTube.Storage.url: $url");
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
        await download.getVideoStream();
        setState(() { });
        // await getVideo();
      }
      print("MyTube.player.download: ${download.fileName}");
    } catch(e) {
      print("MyTube.player: $e");
      alert(context, e.toString());
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

  Future<void> getVideo() async {
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Material(
      child: Container(
        decoration: new BoxDecoration(color: Colors.white),
        padding: EdgeInsets.all(0.0), //容器内补白
        width: double.infinity,
        child: download == null || download.title.length == 0 ? loading() : 
          (width < height  
            ? Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: step2()
            )
            : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: step2()
            )
          )
      )
    );
  }

  Widget loading() {
    return new Center( 
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

  List<Widget> step2(){
    List<Widget> widget = [];
    if(processing == 100)
      widget.add(PlayerControler(fileName: download.fileName));
    widget.add(Expanded( flex: 1,
        child: Container(
          //  margin: const EdgeInsets.all(15.0),
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          // decoration: BoxDecoration(
          //   border: Border.all(color: Colors.blueAccent)
          // ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              if(download.duration.inSeconds > 0)
                Text("時間：" + download.duration.toString().replaceAll(".000000", ""),
                  textAlign: TextAlign.left,
                  style: new TextStyle(
                    // color: Colors.blue,
                    fontSize: 20,
                  )
                ),
              if(processing < 100 && processing > -1)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(height: 30,),
                    LinearProgressIndicator(  
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(Colors.blue),
                      value: processing.toDouble() / 100,  
                    ),
                    Container(height: 10,),
                    Text(processing.toString(),
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                        // color: Colors.blue,
                        fontSize: 20,
                      )
                    ),
                  ]
                ),
              if(download.streams != null && processing == -1)
                list()
            ]
          )
        ),
      )
    );

    return widget;
  }

  final scrollController = ScrollController();
  Widget list(){
    List arr = download.streams.toList();
    return Expanded( flex: 1,
      child: Container(//容器内补白
        decoration: BoxDecoration(
          border: Border.all(color: Colors.lightBlue)
        ),

        margin: EdgeInsets.only(top: 10.0, bottom: 10.0), 
        padding: EdgeInsets.all(0.0),
        child: ListView.builder(
          controller: scrollController,
          shrinkWrap: true,
          itemCount: arr.length,
          itemBuilder: (BuildContext context, int index){ 
            return
            Material(
              child:  InkWell(
                onTap: (){
                  // textEditingControllerD.text = name.replaceAll(path + "/", "");
                },
                // splashColor: Colors.red,
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Cell(
                        Text("${arr[index].size.totalMegaBytes.toStringAsFixed(2) + 'MB'}",
                          style: TextStyle(
                            // color: Colors.red,
                            fontSize: 20,
                          ),
                        )
                      ),
                      Cell(Text("${arr[index].videoQualityLabel}",
                        style: TextStyle(
                          // color: Colors.red,
                          fontSize: 20,
                        ),
                      )),
                      Cell(Text("${arr[index].container.name.toString()}",
                        style: TextStyle(
                          // color: Colors.red,
                          fontSize: 20,
                        ),
                      )),
                    ],
                  )
                )
              )
            ); 
            // Container(
            //   padding: EdgeInsets.only(top: 0.0),
            //   child: Text("${arr[index].size}")
            // );
          },
        )
      )
    );
  }

  Widget list2(){
    return GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, //横轴三个子widget
          childAspectRatio: 1.0 //宽高比为1时，子widget
      ),
      children:<Widget>[
        Icon(Icons.ac_unit),
        Icon(Icons.airport_shuttle),
        Icon(Icons.all_inclusive),
        Icon(Icons.beach_access),
        Icon(Icons.cake),
        Icon(Icons.free_breakfast)
      ]
    );
  }
}

class Cell extends StatelessWidget {
  Widget child;
  int flex;
  double width;
  Cell(this.child, {this.flex = 0, this.width = 0});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Widget view;

    if(width > 0) {
      view = Container(
        width: width,
        child: child
      );
    } else if(flex > 0) {
      view = Expanded(flex: flex, child: child);
    } else {
      view = child;
    }
    return view;
  }
}

class PlayerControler extends StatefulWidget {
  final String fileName;

  PlayerControler({Key? key, required this.fileName}) : super(key: key);

  @override
  _PlayerControlerState createState() => _PlayerControlerState();
}

class _PlayerControlerState extends State<PlayerControler> {
  final eventChannel = const EventChannel('com.flutter/EventChannel');
  VideoPlayerController? _controller;
  Duration _duration = Duration(seconds: 0);
  Duration _position = Duration(seconds: 0);
  var timer;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController
    .file(File("file://" + widget.fileName))
    ..addListener(() {
      Timer.run( () {
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
      // 
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

    eventChannel.receiveBroadcastStream().listen((data) async {
      if(data == "unplugged") {
        _controller!.pause();
      }
    });
  }
  
  @override
  void dispose() {
    _controller!.dispose();
    // if(timer != null) timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    
    return Container(
      width: (width < height ? width : (((height - 160) * _controller!.value.aspectRatio).roundToDouble())),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent)
      ),
      child: Column(children: [
        Container(
          child: _controller!.value.isInitialized
          ? AspectRatio(aspectRatio: _controller!.value.aspectRatio, child: VideoPlayer(_controller!))
          : Container(),
        ),
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
          },
        ),
        Row(
          children: [      
            Material(
              // color: Colors.red,
              child: Ink(
                decoration: ShapeDecoration(
                  // color: Colors.black,
                  shape: CircleBorder(),
                  // shape: Border.all(
                  //   color: Colors.black,
                  //   width: 0,
                  // ) ,
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
              )
            ),
            Text('${_position.toString().substring(0, 7)} / ${_duration.toString().substring(0, 7)}'
              ,style: TextStyle(
              // color: Colors.red,
              fontSize: 18,
            ),),
            // if(_duration.inSeconds > 0)
          ]
        ),
      ]),
    );
  }
}
