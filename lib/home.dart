import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:mytube/video.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
import 'package:mytube/youtube.dart';
import 'package:mytube/system/system.dart';
import 'package:device_info/device_info.dart';
import 'package:mytube/system/playlist.dart';
import 'package:mytube/video/player.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  WebViewController? webViewController;
  final methodChannel = const MethodChannel('com.flutter/MethodChannel');
  final eventChannel = const EventChannel('com.flutter/EventChannel');
  var timer, url = "https://m.youtube.com", permission = false;
  String currentURL = "", versionName = "", playItem = "", operation = "";
  List<ListTile> menuList = [];
  Playlist playlist = Playlist();

  @override
  void initState() {
    super.initState();
    
    eventChannel.receiveBroadcastStream().listen((data) async {
      // print("MyTube.event: $data");
      if(data == "onStop" && webViewController != null) {
        this.webViewController!.readAnchor(false);
        // timer = Timer(Duration(minutes: 20), () {
        //   methodChannel.invokeMethod('finish');
        // });
      } else if(data == "onResume"){
        // if(timer != null) timer.cancel();
        String url = (await this.webViewController!.currentUrl()).toString();
        if(url.indexOf("/watch?") == -1) {
          this.webViewController!.readAnchor(true);
        }
      } else if(data == "unplugged") {
        String url = (await this.webViewController!.currentUrl()).toString();
        if(url.indexOf("/watch?") > -1) {
          await webViewController!.pause();
        }
      }
    });
    if(Platform.isAndroid) {
      new Future.delayed(const Duration(milliseconds: 100), () {
        _requestPermissions().then((permission) async {
          inital(permission);
        });
      });      
    } else {
      inital(true);
    }
  }

  inital(bool permission) async {
    this.permission = permission;
    playItem = await Storage.getString("playItem");
    if(playItem.length == 0)  playItem = "YouTube";
    await playlist.initial();
    await readMenuList();
    this.setState(() {});
  }

  readMenuList() async {
    operation = "";
    menuList = [];
    
    menuList.add(
      ListTile(
        title: Text('YouTube',
          style: TextStyle(
            // color: Colors.red,
            fontSize: 20,
          ),
        ),
        onTap: () async {
          Navigator.pop(context);
          currentURL = "";
          if(playItem == "YouTube") {
            this.webViewController!.reload();
          } else {
            playItem = "YouTube";
            await Storage.setString("playItem", "YouTube");
            setState(() { });
            readMenuList();
          }
        },
        // subtitle: _act != 2 ? const Text('The airplane is only in Act II.') : null,
        // enabled: _act == 2,
        selected: playItem == "YouTube" ? true : false ,
        // leading: const Icon(Icons.flight_land),
      )
    );

    playlist.data.forEach((k, v) {
      menuList.add(
        ListTile(
          title: Text(k,
            style: TextStyle(
              // color: Colors.red,
              fontSize: 20,
            ),
          ),
          onTap: () async {
            await Storage.setString("playItem", k);
            playItem = k;
            readMenuList();
            setState(() { });
            Navigator.pop(context);
          },
          selected: playItem == k ? true : false ,
        )
      );
    });
  }

  Future<bool> _requestPermissions() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    } else
      return false;
  }
  
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    versionName = await methodChannel.invokeMethod('getVersionName');

    String watchID = await Storage.getString("watchID");
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if(androidInfo.model == "V2") watchID = "/watch?v=ZqcIgCDWtGs";
    // watchID = "/watch?v=sTjJ1LlviKM"; // test, 中視颱風
    // watchID = "/watch?v=iP8SqetfseI"; // test, 如實記
    if(playItem == "YouTube" && Platform.isAndroid && watchID.length > 0){
      new Future.delayed(const Duration(milliseconds: 1000 * 3), () {
        openVideo(watchID); // "/watch?v=sTjJ1LlviKM");
      });
    }
  }

  @override
  void reassemble() async { // develope mode
    super.reassemble();
    // playItem = "YouTube";
  }
  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(title: Text(playItem), 
      actions: [
        if(operation == "delete") // 確定刪除
        IconButton(
          icon: Icon(
            Icons.delete,
            color: Colors.white,
          ),
          onPressed: () { 
            var data = playlist.data[playItem] as List;
            for(var i = data.length - 1; i >= 0; i--) {
              if(data[i]["delete"] == true)
                data.removeAt(i);
            }
            playlist.save();
            operation = "";
            setState(() { });
          },
        ),
        if(operation == "delete") // 取消
        IconButton(
          icon: Icon(
            Icons.undo,
            color: Colors.white,
          ),
          onPressed: () {
            var data = playlist.data[playItem] as List;
            for(var i = 0; i < data.length; i++) {
              data[i].remove("delete");
            }
            operation = "";
            setState(() { });
          },
        )
      ]
    );
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Container(
        // padding: EdgeInsets.only(top: 24.0),
        child: Scaffold(
          appBar: playItem == "YouTube" ? null : appBar, // AppBar(title: Text("MyTube")),
          drawer: Drawer(
            child: createMenu(),
          ),
          body: this.permission == true 
            ? (playItem == "YouTube" ? createWeb() : creatPlayList())
            : null,
        ),
      )
    );
  }
  
  Future<bool> _onWillPop() async {
    if(playItem == "YouTube") {
      String currenturl = (await this.webViewController!.currentUrl()).toString();
      print("MyTube.onWillPop.currentUrl: $currenturl");

      if (this.webViewController != null && currenturl != url + "/") {
        if(currenturl.indexOf("list=") > -1 || currenturl.indexOf("/feed/") > -1 || currenturl.indexOf("/user/") > -1 || currenturl.indexOf("/channel/") > -1) 
          this.webViewController!.goBack();
        else if(currenturl.indexOf("/playlists") > -1 || currenturl.indexOf("/videos") > -1 || currenturl.indexOf("/featured") > -1) 
          this.webViewController!.goBack();
        else
          this.webViewController!.loadUrl(url);
        return Future.value(false); // 表示不退出
      }
    }
    return Future.value(true);
  }

  WebView createWeb() {
    return WebView(
      initialUrl: this.url, // 'https://www.youtube.com/',
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) async {
        this.webViewController = webViewController;
      },
      initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
      onProgress: (int progress) async {
        if(progress == 100 ) {
          String url = (await this.webViewController!.currentUrl()).toString();
          if(currentURL != url){
            print("MyTube.onProgress: $url");
            currentURL = url;
            if(url == "https://m.youtube.com/" ) {
              this.webViewController!.setAnchorClick("a.large-media-item-thumbnail-container");
            } else if(url.indexOf("/feed/subscriptions") > -1) {
              this.webViewController!.setAnchorClick(".item a"); // compact-media-item
            } else if(url.indexOf("/channel/") > -1) {
              this.webViewController!.setAnchorClick(".item a");
            } else if(url.indexOf("/user/") > -1) {
              this.webViewController!.setAnchorClick(".compact-media-item a"); // 
            } else if(url.indexOf("playlist?list=") > -1) {
              this.webViewController!.setAnchorClick("a.compact-media-item-image"); 
            } else if(url.indexOf("#") > -1){
            } else if(url.indexOf("/feed/library") > -1 || url.indexOf("/feed/channels") > -1) {
              this.webViewController!.readAnchor(false);
              this.webViewController!.clearIntervalAD();
            } else if(url.indexOf("/watch?") > -1) {
              this.webViewController!.skipAD();
            } else {
              this.webViewController!.clearIntervalAD();
            }            
          }
        }
      },
      // userAgent: "Flutter",
      javascriptChannels: <JavascriptChannel>[
        javascriptChannel(context),
      ].toSet(),
      // navigationDelegate: (NavigationRequest request) async {
      //   print("MyTube.navigationDelegate: ${request.url}");
      //   this.webViewController!.currentUrl().then((value){
      //     print(value);
      //   });
      //   if (request.url.indexOf(".yahoo.") > -1 ||
      //       request.url.indexOf("google") > -1) {
      //     showDialog(
      //         context: context,
      //         builder: (_) {
      //           // return Broswer(url: request.url);
      //         });
      //     return NavigationDecision.prevent;
      //   } else {
      //     return NavigationDecision.navigate;
      //   }
      // },
      onPageStarted: (String url) async {
        print("myTube.onPageStarted.url: ${await this.webViewController!.currentUrl()}");
      },
      onPageFinished: (String url) async {
        print("myTube.onPageFinished.url: ${await this.webViewController!.currentUrl()}");
      },
      debuggingEnabled: true,
      // gestureNavigationEnabled: true,
    );
  }

  Widget creatPlayList(){
    var data = playlist.data[playItem];
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: data.length,
      itemBuilder: (context, index) {
        return  ListTile(
          title: Text((index +1).toString() + ". " + data[index]["title"],
            style: TextStyle(
              // color: Colors.red,
              fontSize: 20,
            ),
          ),
          // subtitle: Text(data[index]["fileName"]),
          // leading: Icon(Icons.more_vert),
          // trailing: (data[index]["active"])
          //         ? Icon(Icons.check_box)
          //         : Icon(Icons.check_box_outline_blank), // ok 的
          trailing: operation == "" ? (data[index]["fileName"] is String && data[index]["fileName"].length > 0 ? Icon(Icons.live_tv_rounded) : null)
            :  (data[index]["delete"] == true ? Icon(Icons.check_box) : Icon(Icons.check_box_outline_blank)),
          onTap: () async {
            if(operation == "") {
              for(var i = 0; i < data.length; i++) {
                if(i == index)
                  data[i]["active"] = true;
                else
                  data[i].remove("active");
                data[i].remove("delete");
              }
              playlist.save();
              if(data[index]["active"] = true)
              openPlayer(data[index]);
            } else {
              data[index]["delete"] = data[index]["delete"] == true ? false : true;
              if(data[index]["delete"] == false) {
                bool b = false;
                for(var i = 0; i < data.length; i++) {
                  if(data[i]["delete"] == true) {
                    b = true;
                    break;
                  }
                }
                if(b == false)
                  operation = "";
              }
            }
            setState(() { });
          },
          onLongPress: () {
            if(operation == "") {
              operation = "delete";
            }
            data[index]["delete"] = true;
            // alert(context, index.toString()); // 可以用的
            setState(() {});
          },
          selected: data[index]["active"] is bool && data[index]["active"] == true 
            || data[index]["delete"] is bool && data[index]["delete"] == true 
            ? true : false ,
        );
      },
      separatorBuilder: (context, index) {
        return Divider();
      }
    );
  }

  Widget createMenu(){
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          width: double.infinity,
          child: Text("MyTube",
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
            ),
          )
        ),
        Expanded(
          flex: 1,
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: menuList.length,
            itemBuilder: (context, index) {
              return menuList[index];
            },
            separatorBuilder: (context, index) {
              return Divider();
            },
          )
        ),
        Container(
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.blue[400],
            border: Border(
              top: BorderSide(width: 2.0, color: Colors.lightBlue.shade600),
            ),//Border.all(color: Colors.blueAccent)
            // bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
          ),
          width: double.infinity,
          child: Row(children: [
            Expanded(
              child: Container(),
              flex: 1
            ),
            Text("by Jim Chen \n $versionName",
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            )
          ])
        ),
      ]
    );
  }

  JavascriptChannel javascriptChannel(BuildContext context) { // 不用了
    return JavascriptChannel( // 接收來自 javascript
      name: 'Flutter',
      onMessageReceived: (JavascriptMessage message) async {
        Map<String, dynamic> obj = jsonDecode(message.message);
        print("$obj");
        if (obj["href"] != null) {
          openVideo(obj["href"]);
        }
      });
  }

  openVideo(String href) async {
    this.webViewController!.clearIntervalAD();
    if(href.indexOf("/watch?") == -1) {
      print("MyTube.openVideo.reload: $href");
      this.webViewController!.loadUrl(url + href);
    } else if(this.webViewController != null) {
      await Storage.setString("watchID", href);
      print("MyTube.openVideo: $href");
      this.webViewController!.readAnchor(false);
      showDialog(
        context: context,
        builder: (_) {
          return Video(url: url + href); 
        }
      ).then((valueFromDialog) async {
        await Storage.setString("watchID", "");
        this.webViewController!.readAnchor(true);
        this.webViewController!.clearIntervalAD();
        await playlist.initial();
        await readMenuList();
        this.setState(() {});
      });
    }
  }
  openPlayer(Map<String, dynamic> item){
    showDialog(
      context: context,
      builder: (_) {
        return Player(url: "", folder: playItem, playItem: item); 
      }
    ).then((valueFromDialog) async {
      
    });
  }
}
