import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:mytube/video.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
import 'package:mytube/youtube.dart';
import 'package:mytube/system/system.dart';
import 'package:mytube/video/fileSave.dart';


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
  String currentURL = "";

  @override
  void initState() {
    super.initState();
    
    eventChannel.receiveBroadcastStream().listen((data) async {
      if(data == "onStop" && webViewController != null) {
        // timer = Timer(Duration(minutes: 20), () {
        //   methodChannel.invokeMethod('finish');
        // });
      } else if(data == "onResume"){
        // if(timer != null) timer.cancel();
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
          this.permission = permission;
          this.setState(() {});
        });
      });      
    } else {
      this.permission = true;
      this.setState(() {});
    }
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

    String watchID = await Storage.getString("watchID");
    // watchID = "/watch?v=sTjJ1LlviKM"; // test, 中視颱風
    // watchID = "/watch?v=iP8SqetfseI"; // test, 如實記
    if(watchID.length > 0 && Platform.isAndroid){
      new Future.delayed(const Duration(milliseconds: 1000 * 3), () {
        openVideo(watchID); // "/watch?v=sTjJ1LlviKM");
      });
    }
  }

  @override
  void reassemble() async { // develope mode
    super.reassemble();
    // fileSave(context, url + "/watch?v=sTjJ1LlviKM");
  }
  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Container(
        padding: EdgeInsets.only(top: 24.0),
        child: this.permission == true ? createWeb() : null,
      )
    );
  }

  Future<bool> _onWillPop() async {
    String currenturl = (await this.webViewController!.currentUrl()).toString();
    // print("MyTube.onWillPop.currentUrl: $currenturl");

    if (this.webViewController != null && currenturl != url + "/") {
      if(currenturl.indexOf("list=") > -1)
        this.webViewController!.goBack();
      else
        this.webViewController!.loadUrl(url);
      return Future.value(false); // 表示不退出
    } else {
      return Future.value(true);
    }
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
              this.webViewController!.anchorClick("a.large-media-item-thumbnail-container");
            } else if(url.indexOf("playlist?list") > -1) {
              this.webViewController!.anchorClick("a.compact-media-item-image");
            } else if(url.indexOf("#") > -1){
            } else if(url.indexOf("feed/library") > -1) {
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

      },
      debuggingEnabled: true,
      // gestureNavigationEnabled: true,
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

  openVideo(href) async {
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
    });
  }
}
