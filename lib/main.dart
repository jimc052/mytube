import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:mytube/video.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

void main() async {
  // if (Platform.isAndroid) {
  //   await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  // }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Tube',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'My Tube'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  WebViewController? webViewController;
  final methodChannel = const MethodChannel('com.flutter/MethodChannel');
  final eventChannel = const EventChannel('com.flutter/EventChannel');
  var timer, url = "https://m.youtube.com", permission = false;

  @override
  void initState() {
    super.initState();
    eventChannel.receiveBroadcastStream().listen((data) async {
      if(data == "onStop" && webViewController != null) {
        timer = Timer(Duration(minutes: 20), () {
          methodChannel.invokeMethod('finish');
        });
      } else if(data == "onResume"){
        if(timer != null) timer.cancel();
      } else if(data == "unplugged") {
        String url = (await this.webViewController?.currentUrl()).toString();
        if(url.indexOf("/watch?") > -1) {
          await webViewController?.evaluateJavascript(
            '''
            {
              let video = document.querySelector("video"); 
              if(video != null && video.paused == false)
                video.pause();
            }
            ''');
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

    // new Future.delayed(const Duration(milliseconds: 1000 * 3), () {
    //   openVideo("/watch?v=-ZQtc0n76Sw");
    // });
  }

  @override
  void reassemble() async {
    super.reassemble();
    
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
    if (this.webViewController != null && await this.webViewController!.canGoBack()) {
      this.webViewController?.loadUrl(url);
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
        if(progress == 100) {
          String url = (await this.webViewController?.currentUrl()).toString();
          if(url.indexOf("#") > -1) {
          } else if(url.indexOf("/watch?") > -1) {
            skipAD();
          } else {
            clearIntervalAD();
          }
        }
      },
      // userAgent: "Flutter",
      javascriptChannels: <JavascriptChannel>[
        _javascriptChannel(context),
      ].toSet(),
      // navigationDelegate: (NavigationRequest request) async {
      //   print("MyTube.navigationDelegate: ${request.url}");
      //   this.webViewController?.currentUrl().then((value){
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
        // print("myTube.onPageStarted.url: ${await this.webViewController?.currentUrl()}");
      },
      onPageFinished: (String url) async {
        interruptClick(url);
        // print("myTube.onPageFinished.url: ${await this.webViewController?.currentUrl()}");
      },
      debuggingEnabled: true,
      // gestureNavigationEnabled: true,
    );
  }
  skipAD() async{ //略過廣告
    await webViewController?.evaluateJavascript(
    '''
      console.log("MyTube: skipAD............")
      if(typeof window.timerAD == "undefined") {
        window.timerAD = setInterval(()=>{
          // Flutter.postMessage(JSON.stringify({x: 0, y: 0})); // 不用了
          let el = document.querySelector(".ytp-ad-skip-button");
          console.log("MyTube: " + (new Date()))
          if(el != null) {
            console.log(el)
            console.lg("MyTube: 略過廣告............");
            el.click();
          }
        }, 1000 * 5)
      }
    ''');
  }
  clearIntervalAD() async {
    await webViewController?.evaluateJavascript(
      '''
      if(typeof window.timerAD != "undefined") {
        console.log("MyTube: clearInterval............")
        clearInterval(window.timerAD)
        delete window.timerAD;
      };
      ''');
  }
  interruptClick(String url) async {
    // https://m.youtube.com/
    await webViewController?.evaluateJavascript(
    '''
    {
      let intervalAnchor = setInterval(()=>{
        let xx = document.querySelectorAll("a.large-media-item-thumbnail-container");
        xx.forEach((item, index) =>{
          // console.log(item)
          let href = item.getAttribute("href");
          if(href.indexOf("javascr") == -1) {
            item.setAttribute("href", "javascript:void(0);");
            // console.log(href);
            item.addEventListener("click", (e)=> {
              e.preventDefault();
              e.stopImmediatePropagation();
              e.stopPropagation();
              Flutter.postMessage(JSON.stringify({href}));
            }, false)
          }
        })
      }, 1 * 1000);
    }

    function MyTubeClick(e) {
      console.log(e)
      console.log("MyTube.Click: " + e.srcElement.getAttribute("href"))
      e.preventDefault();
      e.stopImmediatePropagation();
      e.stopPropagation();

      // Flutter.postMessage(JSON.stringify({}));
      // https://m.youtube.com/watch?v=4KfQ_dtZzhU

    }
    ''');
  }
  

  tap(int x, int y) async { // ok了，但座標還沒寫, 不用了
    var result = await methodChannel.invokeMethod('execCmd', {
      "cmd": "input tap $x $y" // adb shell 
    });
    // print("MyTube: " + result);
  }
  JavascriptChannel _javascriptChannel(BuildContext context) { // 不用了
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

  openVideo(href) {
    print("MyTube.openVideo: $href");
    showDialog(
      context: context,
      builder: (_) {
        return Video(url: url + href); 
      }
    );
  }
}


