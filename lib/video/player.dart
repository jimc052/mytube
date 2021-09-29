import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mytube/download.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:mytube/system/system.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity/connectivity.dart';
import 'package:mytube/video/fileSave.dart';

Download download = new Download();

class Player extends StatefulWidget {
  final String url;
  Player({Key? key, required this.url}) : super(key: key);

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  int processing = -1, streamsTimes = 0;
  var player, timer;

  @override
  void initState() {
    super.initState();
    download = new Download();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    String url = await Storage.getString("url");
    String fileName = await Storage.getString("fileName");
    var file = File(fileName);
    // url = ""; // for test................
    print("MyTube.Storage.url: $url, filtName: $fileName");
    try{
      if(url == this.widget.url && file.existsSync()) {
        download.fileName = await Storage.getString("fileName");
        download.title = await Storage.getString("title");
        download.author = await Storage.getString("author");
        download.mb = await Storage.getString("mb");
        download.duration = Duration(milliseconds: await Storage.getInt("duration"));
        processing = 100;
        setState(() { });
      } else {
        await getStream();
      }
      print("MyTube.player.download: ${download.fileName}");
    } catch(e) {
      print("MyTube.player: $e");
      alert(context, e.toString());
    }
  }

  @override
  dispose() {
    download.stop = true;
    download.dispose();
    Fluttertoast.cancel();
    super.dispose();
  }
  @override
  void reassemble() async {
    super.reassemble();
    streamsTimes = 0;
  }

  Future<void> getStream() async {
    await download.initial(this.widget.url);
    // await download.getVideoStream();
    setState(() { });
  }
  Future<void> getVideo() async {
    Storage.setInt("position", 0);
    try{
      await download.execute(onProcessing: (int process){
        processing = process;
        if(process == 100) {
          Storage.setString("url", this.widget.url);
          Storage.setString("fileName", download.fileName);
          Storage.setString("title", download.title);
          Storage.setString("author", download.author);
          Storage.setString("mb", download.mb);
          Storage.setInt("duration", download.duration.inMilliseconds);
        }
        setState(() { });
      });      
    } catch(e) {
      alert(context, e.toString());
    }
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
        height: double.infinity,
        child: download == null || download.title.length == 0 ? loading() : 
        (width < height  
          ? Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: show()
          )
          : Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: show()
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
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> show(){
    List<Widget> widget = [];
    if(processing == 100)
      widget.add(PlayerControler(fileName: download.fileName, controller: player,));
    widget.add(Expanded( flex: 1,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded( flex: 1, 
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: information()
                  )
                )
              ),
              if(processing == -1)
                Grid(onReady: (result) {
                  print("MyTube.onReady");
                  if(streamsTimes == 0) { // 在第一次自動觸發
                    if(result > 0) toast();
                    streamsTimes = 1;
                  }
                }, onPress: (index) {
                  print("MyTube.onPress: $index");
                  choiceVideo(index);
                }, onChange: (){
                  if(timer != null) timer.cancel();
                }),
              if(processing == 100)
                Row(children: [
                  ElevatedButton(
                    child: Text('重新選擇'),
                    style: ButtonStyle(textStyle: MaterialStateProperty.all(TextStyle(fontSize: 18)),
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 15, vertical: 5))
                    ),
                    onPressed: () async {
                      if(download.streams == null){
                        download.title = "";
                        streamsTimes = 1;
                      }
                      processing = -1;
                      setState(() {});
                      player = null;
                      if(download.streams == null)
                        await getStream();
                    },
                  ),
                  Container(width: 5,),
                  ElevatedButton(
                    child: Text('另存新檔'),
                    style: ButtonStyle(textStyle: MaterialStateProperty.all(TextStyle(fontSize: 18)),
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 15, vertical: 5))
                    ),
                    onPressed: () async {
                      fileSave(context, isLocal: true); 
                    },
                  )
                ]
              ),
              Container(height: 5,)
            ]
          )
        ),
      )
    );
    return widget;
  }

  Widget information(){
    double fontSize = 20 + (MediaQuery.of(context).size.width > 800 ? 4 : 0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 5),
        Text(download.title,
          textAlign: TextAlign.left,
          style: new TextStyle(
            color: Colors.blue,
            fontSize: fontSize,
          )
        ),
        if(download.author.length > 0)
          Text("作者：" + download.author,
            textAlign: TextAlign.left,
            style: new TextStyle(
              // color: Colors.blue,
              fontSize: fontSize - 2,
            )
          ),
        if(download.duration.inSeconds > 0)
          Row(children: [
            Text("時間：" + download.duration.toString().replaceAll(".000000", ""),
              textAlign: TextAlign.left,
              style: new TextStyle(
                // color: Colors.blue,
                fontSize: fontSize - 2,
              )
            ),
            Expanded(flex: 1, child: Container()),
            Text(download.mb,
              textAlign: TextAlign.right,
              style: new TextStyle(
                // color: Colors.blue,
                fontSize: fontSize - 2,
              )
            ),
          ]),
        if(processing < 100 && processing > -1) // LinearProgressIndicator
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
                  color: Colors.blue,
                  fontSize: 20,
                )
              ),
            ]
          )
      ]
    );
  }

  void choiceVideo(index) async {
    if(timer != null) timer.cancel();
    Fluttertoast.cancel();
    download.audio = download.streams.elementAt(index);
    try {
      await getVideo();
    } catch(e) {
    }
   }

  toast() async { // 暫時 mark, 09-27
    int index = 0, sec = 5;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi) {
      if(download.qualityMedium > -1) 
        index = download.qualityMedium;
      else if(download.qualityHigh > -1) 
        index = download.qualityHigh;
    }
    timer = Timer(Duration(seconds: sec), () => choiceVideo(index));

    Fluttertoast.showToast(
      msg: "$sec 秒後，自動選取第 ${index + 1} 個視頻!!",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black45,
      textColor: Colors.white,
      fontSize: 16.0
    );
  }
}

class PlayerControler extends StatefulWidget {
  final String fileName;
  dynamic controller;

  PlayerControler({Key? key, required this.fileName, required this.controller}) : super(key: key);

  @override
  _PlayerControlerState createState() => _PlayerControlerState();
}

class _PlayerControlerState extends State<PlayerControler> {
  final eventChannel = const EventChannel('com.flutter/EventChannel');
  VideoPlayerController? _controller;
  Duration _duration = Duration(seconds: 0);
  Duration _position = Duration(seconds: 0);

  @override
  void initState() {
    super.initState();
    this.widget.controller = this;
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
      if(_controller != null){
        try{
          setState(() {
            _duration = _controller!.value.duration;
          });           
        } catch(e){
        }
      }
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
      if(data == "unplugged" && _controller != null) {
        _controller!.pause();
      }
    });
  }
  
  @override
  void dispose() {
    _controller!.pause();
    _controller!.dispose();
    _controller = null;
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

class Grid extends StatefulWidget {
  Function(int)? onReady;
  Function(int)? onPress;
  Function()? onChange;
  Grid({Key? key, this.onPress, this.onReady, this.onChange}) : super(key: key);

  @override
  _GridState createState() => _GridState();
}

class _GridState extends State<Grid> {
  bool isVideo = false;
  List arr = [];
  
  @override
  void initState() {
    super.initState();
    initial();
  }

  initial() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    isVideo = (connectivityResult == ConnectivityResult.wifi);
    await getStream();
  }

  getStream() async {
    var dialogContext;
    loading(context, onReady: (_) {
      dialogContext = _;
    });
    if (isVideo == false) {
      await download.getAudioStream();
    } else  {
      await download.getVideoStream();
    }

    arr = download.streams.toList();
    if(isVideo == true){
      for(int i = 0; i < arr.length; i++){
        String quality = "${arr[i].videoQuality}".replaceAll("VideoQuality.", "");
        if(quality.indexOf("medium") == 0 &&  download.qualityMedium == -1){
          download.qualityMedium = i;
        } else if(quality.indexOf("high") == 0 &&  download.qualityHigh == -1) {
          download.qualityHigh = i;
          break;
        }
      }      
    }

    if(isVideo == true && arr.length > 7) {
      for(int i = arr.length -1; i >= 0; i--){
        String quality = "${arr[i].videoQuality}".replaceAll("VideoQuality.", "");
        if(quality.indexOf("high") > -1)
          break;
        else
          arr.removeLast();
      }
    }
    this.setState(() {
      Navigator.pop(dialogContext);
    });
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context)  {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        grid(),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(isVideo == true ? '視頻' : '音頻',
              style: TextStyle(
                color: isVideo == true ? Colors.blue : Colors.grey[400],
                fontSize: 20,
              ) 
            ),
            Container(
              width: 80,
              child: Transform.scale( scale: 1.4,
                child: Switch(
                  value: isVideo,
                  onChanged: (value) async {
                    this.widget.onChange!();
                    isVideo = !isVideo;
                    arr = [];
                    setState(() {
                      getStream();
                    });
                  })
              )
            )
          ],
        ),
      ] 
    );
  }

  grid(){
    double width = MediaQuery.of(context).size.width;
    int w = width < 800 ? 150 : 180;
    int cells = (width / w).ceil();
    return Container(
      decoration: BoxDecoration(
        // border: Border.all(color: Colors.lightBlue)
      ),
      margin: EdgeInsets.only(top: 10.0, bottom: 10.0), 
      // padding: EdgeInsets.all(0.0),
      child:  GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cells, //每行三列
            childAspectRatio: 1.2, //显示区域宽高相等
            mainAxisSpacing: 5.0,
            crossAxisSpacing: 5.0,
        ),
        itemCount: arr.length,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          String mb = "${arr[index].size.totalMegaBytes.toStringAsFixed(1) + 'MB'}",
            quality = isVideo == true ? "${arr[index].videoQuality}".replaceAll("VideoQuality.", "") : "";
          Color bg = Colors.grey.shade200, color = Colors.black;
          if(isVideo == true){
            if(quality.indexOf("medium") == 0){
              bg = Colors.green.shade500;
              color = Colors.white;
            } else if(quality.indexOf("high") == 0) {
              bg = Colors.red.shade500; 
              color = Colors.white;
            }  
          }

          double fontSize = width < 800 ? 16 : 24;
          if(index == arr.length -1 && this.widget.onReady is Function) { // 在第一次自動觸發
            this.widget.onReady!(arr.length);
            this.widget.onReady = null;
          }
          return Material(
            child: InkWell(
              onTap: () async {
                arr = [];
                setState(() {
                  this.widget.onPress!(index);
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: bg
                ),
                padding: EdgeInsets.all(5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text( mb,
                      style: TextStyle(
                        color: color,
                        fontSize: fontSize,
                      ),
                    ),
                    if(quality.length > 0)
                      Container(height: 5),
                    if(quality.length > 0)
                      Text( quality,
                        style: TextStyle(
                          color: color,
                          fontSize: fontSize,
                        ),
                      ),
                    Container(height: 5,),
                    Text("${arr[index].container.name.toString()}",
                      style: TextStyle(
                        color: color,
                        fontSize: fontSize,
                      ),
                    ),
                  ],
                )
            )
          )
        ); 
        }
      )
    );
  }
}