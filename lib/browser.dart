import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mytube/download.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:video_player/video_player.dart';

class Browser extends StatefulWidget {
  final String url;

  Browser({Key? key, required this.url}) : super(key: key);

  @override
  _BrowserState createState() => _BrowserState();
}


class _BrowserState extends State<Browser> with WidgetsBindingObserver {
  WebViewController? webViewController;
  @override
  void initState() {
    super.initState();
    
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
