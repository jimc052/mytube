import 'dart:convert';
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
// import 'package:flutter/services.dart';
// import 'package:mytube/system/global.dart' as global;
import 'package:mytube/system/history.dart';
import 'package:mytube/extension/extension.dart';

Download download = new Download();
Map<String, dynamic> historys = {};
class Player extends StatefulWidget {
  final String url;
  final String folder;
  final Map<String, dynamic> playItem;
  Player({Key? key, required this.url, this.folder = "", required this.playItem}) : super(key: key);

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  int processing = -1, streamsTimes = 0;
  var player, timerChoice;
  String videoKey = "";
  
  @override
  void initState() {
    super.initState();
    download = new Download();
    videoKey = Download.parselKey(this.widget.url);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    try{
      if(this.widget.playItem["fileName"] is String) {
        var path = await Download.folder();
        if(this.widget.playItem["fileName"].indexOf(path) > -1) {
          download.fileName = this.widget.playItem["fileName"];
        } else {
          download.fileName = path + "/" + this.widget.folder + "/" + this.widget.playItem["fileName"];
        }
        
        download.title = this.widget.playItem["title"];
        download.author = this.widget.playItem["author"];
        download.mb = this.widget.playItem["mb"] is String ? this.widget.playItem["mb"] : "";
        download.duration = Duration(milliseconds: this.widget.playItem["duration"] is int ? this.widget.playItem["duration"] : 0);
        processing = 100;
        setState(() {});
      } else {
        String s = await Storage.getString("historys");
        if(s.length > 0) {
          historys = jsonDecode(s);
          var arr = [];
          var day10 = DateTime.now().add(const Duration(days: -10)).formate();
          historys.forEach((k, v) {
            Map<String, dynamic> history = jsonDecode(v);
            print("MyTbue.history: $history");
            var date = '''${history['date']}''';
            if(date.compareTo(day10) == -1) {
              arr.add(k);
            }
          });

          arr.forEach((el) {
            historys.remove(el);
          });
          if(arr.length > 0)
            await Storage.setString("historys", jsonEncode(historys));
        }
        if(historys.containsKey(videoKey)) {
          Map<String, dynamic> history = jsonDecode(historys[videoKey]);
          var title = '''${history['title']}''';
          if(title.length > 30) title = title.substring(0, 30) + "...";
          if(processing != -9999)
            alert(context, '''標題：$title\n\n觀看時間：${history['date']}\n\n是否確定再次觀看???''',
            title: "觀看記錄",
            actions: [{"text": "取消", 
                "onPressed": (){
                  Navigator.pop(context);
                }
              }, {"text": "確定", 
              "onPressed": () async {
                await getStream();
              }
            }]
          );
        } else
          await getStream();
      }
    } catch(e) {
      print("MyTube.player: $e");
      if(processing != -9999)
        alert(context, e.toString());
    }
  }

  @override
  dispose() {
    processing = -9999;
    download.stop = true;
    download.dispose();
    Fluttertoast.cancel();
    super.dispose();
  }
  @override
  void reassemble() async {
    super.reassemble();
  }

  Future<void> getStream() async {
    var url = this.widget.url;
    if(url.length == 0 && this.widget.playItem["key"] is String) {
      url = "https://m.youtube.com/watch?v=" + this.widget.playItem["key"];
    }
    await download.initial(url);
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
        child: download == null || download.title.length == 0 ? circularProgressIndicator() : 
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

  Widget circularProgressIndicator() {
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
    double height = MediaQuery.of(context).size.height;

    List<Widget> widget = [];
    if(processing == 100)
      widget.add(PlayerControler(fileName: download.fileName, videoKey: videoKey, controller: player,));
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
                Grid(mode: download.mode,
                  onReady: (result) {
                    if(streamsTimes == 0) { // 在第一次自動觸發
                      if(result > 0) toast();
                      streamsTimes = 1;
                    }
                  }, onPress: (index) {
                    choiceVideo(index);
                  }, onChange: (){
                    if(timerChoice != null) timerChoice.cancel();
                    Fluttertoast.cancel();
                  }
                ),
              Row(children: [
                if(processing > -1) 
                  ElevatedButton(
                    child: Text('重新選擇'),
                    style: ButtonStyle(textStyle: MaterialStateProperty.all(TextStyle(fontSize: 18)),
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 15, vertical: height > 800 ? 10 : 5))
                    ),
                    onPressed: () async {
                      if(download.streams == null){
                        download.title = "";
                        streamsTimes = 1;
                      }
                      download.stop = true;
                      processing = -1;
                      setState(() {});
                      player = null;
                      if(download.streams == null)
                        await getStream();
                    },
                  ),
                if(processing == 100) Container(width: 5),
                if(processing == 100) 
                  ElevatedButton(
                    child: Text('另存新檔'),
                    style: ButtonStyle(textStyle: MaterialStateProperty.all(TextStyle(fontSize: 18)),
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 15, vertical:  height > 800 ? 10 : 5))
                    ),
                    onPressed: () async {
                      fileSave(context, 
                        videoKey: videoKey,
                        fileName: download.fileName,
                        title: download.title, 
                        author: download.author
                      ); 
                    },
                  )
              ]),
              Container(height: 5,)
            ]
          )
        ),
      )
    );
    return widget;
  }

  Widget information(){
    var width = MediaQuery.of(context).size.width;
    double fontSize = 20 + (width > 800 ? 4 : 0);
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
        if(width < 800)
          Container(height: 20,),
        if(processing < 100 && processing > -1) // 下載進度
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
    if(timerChoice != null) timerChoice.cancel();
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
    timerChoice = Timer(Duration(seconds: sec), () => choiceVideo(index));

    Fluttertoast.showToast(
      msg: "$sec 秒後，自動選取第 ${index + 1} 個選項!!",
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
  final String fileName, videoKey;
  dynamic controller;

  PlayerControler({Key? key, required this.fileName, required this.videoKey, required this.controller}) : super(key: key);

  @override
  _PlayerControlerState createState() => _PlayerControlerState();
}

class _PlayerControlerState extends State<PlayerControler> {
  final eventChannel = const EventChannel('com.flutter/EventChannel');
  VideoPlayerController? _controller;
  Duration _duration = Duration(seconds: 0);
  Duration _position = Duration(seconds: 0);
  final methodChannel = const MethodChannel('com.flutter/MethodChannel');
  var interval, state = "onResume";

  @override
  void initState() {
    super.initState();
    this.widget.controller = this;
    _controller = VideoPlayerController
    .file(File("file://" + widget.fileName))
    ..addListener(() {
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
      setState(() async {
        int position = await Storage.getInt("position");
        if(position > 0)
          _controller!.seekTo(Duration(seconds: position));
        play();
      });
    });

    eventChannel.receiveBroadcastStream().listen((data) async {
      print("MyTube.event: " + data);
      if(_controller != null) {
        if((data == "unplugged" || data == "action.TOGGLE") && _controller!.value.isPlaying == true) {
          pause();
        } else if(data == "action.TOGGLE" && _controller!.value.isPlaying == false) {
          play();
        } else if(data == "action.STOP"){
          stop();
          this.setState((){});
        } else if(data == "onPause") {
          state = data;
        } else if(data == "onResume") {
          state = data;
        }
      }
    });
  }
  
  @override
  void reassemble() async { // develope mode
    super.reassemble();
  }
  @override
  void dispose() {
    stop();
    _controller!.dispose();
    _controller = null;
    super.dispose();
  }

  play() async {
    saveHistory();
    setInterval();
    _controller!.play();
    await methodChannel.invokeMethod('play', {
      "title": download.title,
      "author": download.author,
      "position": ""
    });
  }
  pause() async {
    saveHistory();
    _controller!.pause();
    await methodChannel.invokeMethod('pause', {
      "title": download.title,
      "author": download.author,
    });
  }
  stop() async {
    if(interval != null) interval.cancel();
    _controller!.pause();
    _controller!.seekTo(Duration(seconds: 0));
    Storage.setInt("position", 0);
    _position = Duration(seconds: 0);
    await methodChannel.invokeMethod('stop');
    saveHistory();
  }

   saveHistory() async {
    final DateTime now = DateTime.now();
    History h = History(download.title, download.author, 
      now.formate(), 
      '${_position.toString().substring(0, 7)} / ${_duration.toString().substring(0, 7)}');
    historys[this.widget.videoKey] = jsonEncode(h);
    // print("MyTube.history: ${jsonEncode(h)}");
    await Storage.setString("historys", jsonEncode(historys));
  }

  DateTime dtFirst = DateTime.now();
  setInterval(){ // ==========================
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      interval = timer;
      if(_controller!.value.isPlaying == true){
        _position = _controller!.value.position;
        if(_position.inSeconds > 0 && _duration.inMilliseconds - _position.inMilliseconds <= 600) {
          stop();
          setState(() { });
        } else {
          if(DateTime.now().difference(dtFirst).inSeconds >= 10) {
            dtFirst = DateTime.now();
            if(_controller!.value.isPlaying == false) {
              stop();
              setState(() { });
            }
            Storage.setInt("position", _position.inSeconds);
            methodChannel.invokeMethod('play', {
              "title": download.title,
              "author": download.author,
              "position": '${_position.toString().substring(0, 7)} / ${_duration.toString().substring(0, 7)}'
            });
          }
          if(state == "onResume") {
            this.setState((){});
          }
        }
      } else {
        interval.cancel();
        setState(() { });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double aspectRatio = download.mode == Mode.audio && width < height ? 4.0 : _controller!.value.aspectRatio;
    
    return Container(
      width: (width < height ? width : (((height - 160) * _controller!.value.aspectRatio).roundToDouble())),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent)
      ),
      child: Column(children: [
        Container(
          child: _controller!.value.isInitialized
          ? AspectRatio(aspectRatio: aspectRatio, child: VideoPlayer(_controller!))
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
              Timer(Duration(milliseconds: 300), () {
                _position = _controller!.value.position;
                this.setState((){});
              });
            });
          },
        ),
        Row(
          children: [      
            Container(width: 5),
            Material(
              // color: Colors.red,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: !_controller!.value.isPlaying ? Colors.black54 : Colors.grey.shade300, width: 2),
                  // color: Colors.yellow,
                ),
                child:  Container(
                  padding: const EdgeInsets.all(0.0),
                  width: 40.0,
                  height: 40.0,
                  child: IconButton(
                    icon: Icon(_controller!.value.isPlaying ? Icons.pause : Icons.play_arrow),
                    color: !_controller!.value.isPlaying ?  Colors.black54 : Colors.grey.shade300,
                    iconSize: 20,
                    onPressed: () {
                      _controller!.value.isPlaying ? pause() : play();
                      setState(() { });
                    },
                  )
                )
              ),
            ),
            Container(width: 10),
            Text('${_position.toString().substring(0, 7)} / ${_duration.toString().substring(0, 7)}'
              ,style: TextStyle(
              // color: Colors.red,
              fontSize: 20,
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
  Mode mode;
  Grid({Key? key, this.mode = Mode.none, this.onPress, this.onReady, this.onChange}) : super(key: key);

  @override
  _GridState createState() => _GridState();
}

class _GridState extends State<Grid> {
  bool isVideo = false;
  List arr = [];
  var loadingContext;
  
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () => initial());
  }

  initial() async {
    if(this.widget.mode == Mode.none) {
      var width = MediaQuery.of(context).size.width;
      if(width > 800) {
        var connectivityResult = await Connectivity().checkConnectivity();
        isVideo = (connectivityResult == ConnectivityResult.wifi);
      }
    } else {
      isVideo = this.widget.mode == Mode.video ? true : false;
    }
    await getStream();
  }

  @override
  void reassemble() async { // develope mode
    super.reassemble();
    // isVideo = false;
    // await getStream();
  }

  getStream() async {
    loading(context, onReady: (_) {
      loadingContext = _;
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
    } else if(arr.length > 0) {
      var size = 0.0, index = 0;
      for(int i = 0; i < arr.length; i++){
        // print("MyTube.audio $i: ${arr[i].size.totalMegaBytes.toStringAsFixed(2) + 'MB'} ==");
        if(arr[i].size.totalMegaBytes < size || i == 0) {
          size = arr[i].size.totalMegaBytes;
          index = i;
        }
      }
      download.qualityMedium = index;
      // print("MyTube.audio $index: ${arr[index].size.totalMegaBytes.toStringAsFixed(2) + 'MB'} ==========================");
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
      if(loadingContext != null)
        Navigator.pop(loadingContext);
      loadingContext = null;
    });
  }
  
  @override
  void dispose() {
    if(loadingContext != null)
      Navigator.pop(loadingContext);
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
            Text('音頻',
              style: TextStyle(
                color: isVideo == false ? Colors.blue : Colors.grey[400],
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
            ),
            Text('視頻',
              style: TextStyle(
                color: isVideo == true ? Colors.blue : Colors.grey[400],
                fontSize: 20,
              ) 
            ),
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
          } else if(download.qualityMedium == index) {
            bg = Colors.green.shade500; 
            color = Colors.white;
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
