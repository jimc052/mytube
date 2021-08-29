import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

class Browser extends StatefulWidget {
  final String url;

  Browser({Key? key, required this.url}) : super(key: key);

  @override
  _BrowserState createState() => _BrowserState();
}


class _BrowserState extends State<Browser> with WidgetsBindingObserver {
  WebViewController? webViewController;
  var timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // 要 mark 不然 pause
    switch (state) {
      case AppLifecycleState.paused:
        timer = Timer(Duration(minutes: 20), () { // video.dart 要 pop
          pause();
        }); 
        break;
      case AppLifecycleState.resumed:
        if(timer != null) timer.cancel();
        break;
      default:
    }
  }
  
  @override
  void dispose() {
    print("MyTube.broswer: dispose.....................");
    WidgetsBinding.instance!.removeObserver(this);
    this.webViewController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: this.widget.url,
      initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) async {
        this.webViewController = webViewController;
      },
      // javascriptChannels: <JavascriptChannel>[
      //   _javascriptChannel(context),
      // ].toSet(),
      onProgress: (int progress) async {
        if(progress == 100) {
          String url = (await this.webViewController?.currentUrl()).toString();
          if(url.indexOf("/watch?") > -1) {
            unmuted();
          } 
        }
      },
      onPageStarted: (String url) {},
      onPageFinished: (String url) async {
      },
      gestureNavigationEnabled: true,
      debuggingEnabled: true,
    );
  }

  pause() async {
    await webViewController?.evaluateJavascript(
      '''
      {
        let video = document.querySelector("video"); 
        if(video != null && video.paused == false)
          video.pause();
      }
      ''');
  }
  unmuted() async{ //
    await webViewController?.evaluateJavascript(
    '''
      if(typeof window.muted == "undefined") {
        window.muted = false;
        console.log("MyTube: mute............")
        setTimeout(()=>{
          click("ytp-unmute");
          let video = document.querySelector("video"); 
          video.play();
        }, 100 * 6)
      }

      function click(cls){
        let el = document.querySelector("." + cls) ;
        if(el != null) {
          el.click();
          return true;
        } else {
          return false;
        }
      }
    ''');
  }
}
